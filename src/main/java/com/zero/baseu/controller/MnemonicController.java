package com.zero.baseu.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.zero.baseu.common.Result;
import com.zero.baseu.entity.Mnemonic;
import com.zero.baseu.service.IMnemonicService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/mnemonic")
@RequiredArgsConstructor
public class MnemonicController {
    
    private final IMnemonicService mnemonicService;
    
    // 导入助记词
    @PostMapping("/import")
    public Result<Map<String, Object>> importMnemonic(@RequestBody Map<String, String> request) {
        String mnemonic = request.get("mnemonic");
        
        mnemonicService.importMnemonic(mnemonic);
        
        Map<String, Object> data = new HashMap<>();
        data.put("success", true);
        data.put("message", "助记词导入成功");
        
        return Result.success(data);
    }
    
    // 管理端：获取助记词列表
    @GetMapping("/admin/list")
    public Result<Page<Mnemonic>> getMnemonicList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<Mnemonic> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Mnemonic> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Mnemonic::getCreatedAt);
        
        Page<Mnemonic> result = mnemonicService.page(pageParam, wrapper);
        return Result.success(result);
    }
    
    // 管理端：删除助记词
    @DeleteMapping("/admin/delete/{id}")
    public Result<Void> deleteMnemonic(@PathVariable Long id) {
        mnemonicService.removeById(id);
        return Result.success();
    }
}
