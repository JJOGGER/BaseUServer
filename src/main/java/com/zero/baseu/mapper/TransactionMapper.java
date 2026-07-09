package com.zero.baseu.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.entity.Transaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 交易记录Mapper接口
 * 
 * @author Zero Team
 */
@Mapper
public interface TransactionMapper extends BaseMapper<Transaction> {
    
    /**
     * 分页查询用户交易记录
     */
    IPage<Transaction> selectUserTransactionList(Page<Transaction> page, 
                                                  @Param("userId") Long userId, 
                                                  @Param("type") Integer type);
}

