package com.zero.baseu.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.zero.baseu.common.Result;
import com.zero.baseu.dto.request.RechargeRequest;
import com.zero.baseu.dto.response.RechargeResponse;
import com.zero.baseu.entity.Recharge;
import com.zero.baseu.service.IRechargeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 充值控制器
 * 
 * @author Zero Team
 */
@Tag(name = "充值管理", description = "充值订单创建、查询等接口")
@RestController
@RequestMapping("/api/recharge")
@RequiredArgsConstructor
public class RechargeController {
    
    private final IRechargeService rechargeService;
    
    /**
     * 创建充值订单
     */
    @Operation(summary = "创建充值订单")
    @PostMapping("/create")
    public Result<RechargeResponse> createRecharge(Authentication authentication,
                                                    @Valid @RequestBody RechargeRequest request) {
        Long userId = Long.parseLong(authentication.getName());
        RechargeResponse response = rechargeService.createRecharge(userId, request);
        return Result.success("订单创建成功", response);
    }
    
    /**
     * 查询充值记录
     */
    @Operation(summary = "查询充值记录")
    @GetMapping("/list")
    public Result<IPage<Recharge>> getRechargeList(Authentication authentication,
                                                    @RequestParam(defaultValue = "1") Integer page,
                                                    @RequestParam(defaultValue = "10") Integer size,
                                                    @RequestParam(required = false) Integer status) {
        Long userId = Long.parseLong(authentication.getName());
        IPage<Recharge> result = rechargeService.getRechargeList(userId, page, size, status);
        return Result.success(result);
    }
    
    /**
     * 充值回调（支付平台调用）
     */
    @Operation(summary = "充值回调")
    @PostMapping("/callback/{channel}")
    public Result<Void> rechargeCallback(@PathVariable String channel,
                                         @RequestBody String callbackData) {
        // 这里应该根据不同的支付渠道解析回调数据
        // 简化处理
        return Result.success();
    }
}

