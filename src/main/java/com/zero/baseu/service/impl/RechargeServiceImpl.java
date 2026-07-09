package com.zero.baseu.service.impl;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.common.BusinessException;
import com.zero.baseu.common.ResultCode;
import com.zero.baseu.dto.request.RechargeRequest;
import com.zero.baseu.dto.response.RechargeResponse;
import com.zero.baseu.entity.Recharge;
import com.zero.baseu.entity.UserAccount;
import com.zero.baseu.mapper.RechargeMapper;
import com.zero.baseu.mapper.UserAccountMapper;
import com.zero.baseu.service.IRechargeService;
import com.zero.baseu.service.ITransactionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 充值服务实现
 * 
 * @author Zero Team
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RechargeServiceImpl implements IRechargeService {
    
    private final RechargeMapper rechargeMapper;
    private final UserAccountMapper userAccountMapper;
    private final ITransactionService transactionService;
    
    @Override
    public RechargeResponse createRecharge(Long userId, RechargeRequest request) {
        // 生成订单号
        String orderNo = "RC" + IdUtil.getSnowflakeNextIdStr();
        
        // 创建充值记录
        Recharge recharge = new Recharge();
        recharge.setOrderNo(orderNo);
        recharge.setUserId(userId);
        recharge.setAmount(request.getAmount());
        recharge.setCurrency("CNY");
        recharge.setPaymentMethod(request.getPaymentMethod());
        recharge.setStatus(0); // 待支付
        rechargeMapper.insert(recharge);
        
        // 这里应该调用第三方支付接口，获取支付URL和二维码
        // 简化处理，返回模拟数据
        return RechargeResponse.builder()
                .orderNo(orderNo)
                .amount(request.getAmount())
                .paymentUrl("https://payment.example.com/" + orderNo)
                .qrCode("data:image/png;base64,...")
                .build();
    }
    
    @Override
    public IPage<Recharge> getRechargeList(Long userId, Integer page, Integer size, Integer status) {
        Page<Recharge> pageParam = new Page<>(page, size);
        return rechargeMapper.selectUserRechargeList(pageParam, userId, status);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleRechargeCallback(String orderNo, String transactionId) {
        // 查询充值订单
        Recharge recharge = rechargeMapper.findByOrderNo(orderNo);
        if (recharge == null) {
            throw new BusinessException(ResultCode.RECHARGE_ORDER_NOT_FOUND);
        }
        
        // 防止重复处理
        if (recharge.getStatus() == 2) {
            log.warn("充值订单已处理: {}", orderNo);
            return;
        }
        
        // 查询用户账户
        UserAccount account = userAccountMapper.findByUserId(recharge.getUserId());
        if (account == null) {
            throw new BusinessException("用户账户不存在");
        }
        
        BigDecimal balanceBefore = account.getBalance();
        
        // 增加余额（使用乐观锁）
        int updated = userAccountMapper.increaseBalance(
                recharge.getUserId(), 
                recharge.getAmount(),
                account.getVersion()
        );
        
        if (updated == 0) {
            throw new BusinessException("账户更新失败，请重试");
        }
        
        // 更新充值状态
        recharge.setStatus(2); // 成功
        recharge.setTransactionId(transactionId);
        recharge.setPayTime(LocalDateTime.now());
        rechargeMapper.updateById(recharge);
        
        // 创建交易记录
        BigDecimal balanceAfter = balanceBefore.add(recharge.getAmount());
        transactionService.createTransaction(
                recharge.getUserId(),
                1, // 充值
                recharge.getAmount(),
                balanceBefore,
                balanceAfter,
                recharge.getId(),
                "充值"
        );
    }
}

