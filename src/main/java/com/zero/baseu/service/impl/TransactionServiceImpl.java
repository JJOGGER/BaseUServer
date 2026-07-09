package com.zero.baseu.service.impl;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.entity.Transaction;
import com.zero.baseu.mapper.TransactionMapper;
import com.zero.baseu.service.ITransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

/**
 * 交易服务实现
 * 
 * @author Zero Team
 */
@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements ITransactionService {
    
    private final TransactionMapper transactionMapper;
    
    @Override
    public IPage<Transaction> getTransactionList(Long userId, Integer page, Integer size, Integer type) {
        Page<Transaction> pageParam = new Page<>(page, size);
        return transactionMapper.selectUserTransactionList(pageParam, userId, type);
    }
    
    @Override
    public void createTransaction(Long userId, Integer type, BigDecimal amount,
                                  BigDecimal balanceBefore, BigDecimal balanceAfter,
                                  Long relatedId, String remark) {
        Transaction transaction = new Transaction();
        transaction.setTransactionNo("TX" + IdUtil.getSnowflakeNextIdStr());
        transaction.setUserId(userId);
        transaction.setType(type);
        transaction.setAmount(amount);
        transaction.setBalanceBefore(balanceBefore);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setRelatedId(relatedId);
        transaction.setRemark(remark);
        transactionMapper.insert(transaction);
    }
}

