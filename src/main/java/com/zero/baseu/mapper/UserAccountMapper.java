package com.zero.baseu.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.zero.baseu.entity.UserAccount;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;

/**
 * 用户账户Mapper接口
 * 
 * @author Zero Team
 */
@Mapper
public interface UserAccountMapper extends BaseMapper<UserAccount> {
    
    /**
     * 根据用户ID查询账户
     */
    UserAccount findByUserId(@Param("userId") Long userId);
    
    /**
     * 增加余额
     */
    int increaseBalance(@Param("userId") Long userId, 
                        @Param("amount") BigDecimal amount,
                        @Param("version") Integer version);
    
    /**
     * 减少余额
     */
    int decreaseBalance(@Param("userId") Long userId, 
                        @Param("amount") BigDecimal amount,
                        @Param("version") Integer version);
}

