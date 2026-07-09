package com.zero.baseu.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.zero.baseu.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户Mapper接口
 * 
 * @author Zero Team
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
    
    /**
     * 根据邮箱查询用户
     */
    User findByEmail(@Param("email") String email);
    
    /**
     * 根据手机号查询用户
     */
    User findByPhone(@Param("phone") String phone);
    
    /**
     * 更新最后登录时间
     */
    void updateLastLoginTime(@Param("userId") Long userId);
}

