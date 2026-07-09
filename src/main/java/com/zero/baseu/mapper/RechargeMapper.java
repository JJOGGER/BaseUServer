package com.zero.baseu.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.entity.Recharge;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 充值记录Mapper接口
 * 
 * @author Zero Team
 */
@Mapper
public interface RechargeMapper extends BaseMapper<Recharge> {
    
    /**
     * 根据订单号查询
     */
    Recharge findByOrderNo(@Param("orderNo") String orderNo);
    
    /**
     * 分页查询用户充值记录
     */
    IPage<Recharge> selectUserRechargeList(Page<Recharge> page, 
                                            @Param("userId") Long userId, 
                                            @Param("status") Integer status);
}

