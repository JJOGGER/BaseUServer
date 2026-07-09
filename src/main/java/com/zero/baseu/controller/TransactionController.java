package com.zero.baseu.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.zero.baseu.common.Result;
import com.zero.baseu.entity.Transaction;
import com.zero.baseu.service.ITransactionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 交易控制器
 * 
 * @author Zero Team
 */
@Tag(name = "交易管理", description = "交易记录查询接口")
@RestController
@RequestMapping("/api/transaction")
@RequiredArgsConstructor
public class TransactionController {
    
    private final ITransactionService transactionService;
    
    /**
     * 查询交易记录
     */
    @Operation(summary = "查询交易记录")
    @GetMapping("/list")
    public Result<IPage<Transaction>> getTransactionList(Authentication authentication,
                                                          @RequestParam(defaultValue = "1") Integer page,
                                                          @RequestParam(defaultValue = "10") Integer size,
                                                          @RequestParam(required = false) Integer type) {
        Long userId = Long.parseLong(authentication.getName());
        IPage<Transaction> result = transactionService.getTransactionList(userId, page, size, type);
        return Result.success(result);
    }
}

