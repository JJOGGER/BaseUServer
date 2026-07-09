package com.zero.baseu.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.zero.baseu.dto.request.RechargeRequest;
import com.zero.baseu.dto.response.RechargeResponse;
import com.zero.baseu.entity.Recharge;

/**
 * 充值服务接口
 * 
 * @author Zero Team
 */
public interface IRechargeService {
    
    /**
     * 创建充值订单
     */
    RechargeResponse createRecharge(Long userId, RechargeRequest request);
    
    /**
     * 查询充值记录列表
     */
    IPage<Recharge> getRechargeList(Long userId, Integer page, Integer size, Integer status);
    
    /**
     * 处理充值回调
     */
    void handleRechargeCallback(String orderNo, String transactionId);
}

