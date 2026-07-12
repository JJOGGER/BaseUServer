package com.zero.baseu.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.common.Result;
import com.zero.baseu.entity.Transaction;
import com.zero.baseu.mapper.TransactionMapper;
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
    private final TransactionMapper transactionMapper;
    
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
    
    /**
     * 管理员：获取所有交易记录
     */
    @Operation(summary = "获取所有交易记录")
    @GetMapping("/admin/list")
    public Result<IPage<Transaction>> getAllTransactions(@RequestParam(defaultValue = "1") Integer page,
                                                          @RequestParam(defaultValue = "10") Integer size,
                                                          @RequestParam(required = false) Integer type) {
        Page<Transaction> pageParam = new Page<>(page, size);
        IPage<Transaction> result = transactionMapper.selectPage(pageParam, null);
        return Result.success(result);
    }
    
    /**
     * 管理员：创建交易记录
     */
    @Operation(summary = "创建交易记录")
    @PostMapping("/admin/create")
    public Result<Transaction> createTransaction(@RequestBody Transaction transaction) {
        transactionMapper.insert(transaction);
        return Result.success("交易记录创建成功", transaction);
    }
    
    /**
     * 管理员：更新交易记录
     */
    @Operation(summary = "更新交易记录")
    @PutMapping("/admin/update")
    public Result<Void> updateTransaction(@RequestBody Transaction transaction) {
        transactionMapper.updateById(transaction);
        return Result.success("交易记录更新成功", null);
    }
    
    /**
     * 管理员：删除交易记录
     */
    @Operation(summary = "删除交易记录")
    @DeleteMapping("/admin/delete/{id}")
    public Result<Void> deleteTransaction(@PathVariable Long id) {
        transactionMapper.deleteById(id);
        return Result.success("交易记录删除成功", null);
    }
}

