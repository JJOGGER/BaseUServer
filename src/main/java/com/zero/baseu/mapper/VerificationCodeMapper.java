package com.zero.baseu.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.zero.baseu.entity.VerificationCode;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 验证码Mapper接口
 * 
 * @author Zero Team
 */
@Mapper
public interface VerificationCodeMapper extends BaseMapper<VerificationCode> {
    
    /**
     * 查询最新的有效验证码
     */
    VerificationCode findLatestValidCode(@Param("target") String target, 
                                         @Param("type") Integer type);
}

