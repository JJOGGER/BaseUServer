package com.zero.baseu.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.zero.baseu.entity.Transaction;

import java.math.BigDecimal;

/**
 * 交易服务接口
 * 
 * @author Zero Team
 */
public interface ITransactionService {
    
    /**
     * 查询交易记录列表
     */
    IPage<Transaction> getTransactionList(Long userId, Integer page, Integer size, Integer type);
    
    /**
     * 创建交易记录
     */
    void createTransaction(Long userId, Integer type, BigDecimal amount, 
                          BigDecimal balanceBefore, BigDecimal balanceAfter,
                          Long relatedId, String remark);
}

