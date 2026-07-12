package com.zero.baseu.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.common.Result;
import com.zero.baseu.dto.request.RechargeRequest;
import com.zero.baseu.dto.response.RechargeResponse;
import com.zero.baseu.entity.Recharge;
import com.zero.baseu.mapper.RechargeMapper;
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
    private final RechargeMapper rechargeMapper;
    
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
    
    /**
     * 管理员：获取所有充值记录
     */
    @Operation(summary = "获取所有充值记录")
    @GetMapping("/admin/list")
    public Result<IPage<Recharge>> getAllRecharges(@RequestParam(defaultValue = "1") Integer page,
                                                    @RequestParam(defaultValue = "10") Integer size,
                                                    @RequestParam(required = false) Integer status) {
        Page<Recharge> pageParam = new Page<>(page, size);
        IPage<Recharge> result = rechargeMapper.selectPage(pageParam, null);
        return Result.success(result);
    }
    
    /**
     * 管理员：创建充值记录
     */
    @Operation(summary = "创建充值记录")
    @PostMapping("/admin/create")
    public Result<Recharge> createRecharge(@RequestBody Recharge recharge) {
        rechargeMapper.insert(recharge);
        return Result.success("充值记录创建成功", recharge);
    }
    
    /**
     * 管理员：更新充值记录
     */
    @Operation(summary = "更新充值记录")
    @PutMapping("/admin/update")
    public Result<Void> updateRecharge(@RequestBody Recharge recharge) {
        rechargeMapper.updateById(recharge);
        return Result.success("充值记录更新成功", null);
    }
    
    /**
     * 管理员：删除充值记录
     */
    @Operation(summary = "删除充值记录")
    @DeleteMapping("/admin/delete/{id}")
    public Result<Void> deleteRecharge(@PathVariable Long id) {
        rechargeMapper.deleteById(id);
        return Result.success("充值记录删除成功", null);
    }
}

