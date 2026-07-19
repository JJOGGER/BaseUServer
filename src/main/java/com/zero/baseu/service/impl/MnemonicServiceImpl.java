package com.zero.baseu.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.zero.baseu.common.BusinessException;
import com.zero.baseu.common.ResultCode;
import com.zero.baseu.entity.Mnemonic;
import com.zero.baseu.mapper.MnemonicMapper;
import com.zero.baseu.service.IMnemonicService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
public class MnemonicServiceImpl extends ServiceImpl<MnemonicMapper, Mnemonic> implements IMnemonicService {
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void importMnemonic(String mnemonic) {
        if (!StringUtils.hasText(mnemonic)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "助记词不能为空");
        }
        
        Mnemonic newMnemonic = new Mnemonic();
        newMnemonic.setEncryptedMnemonic(encryptMnemonic(mnemonic.trim()));
        newMnemonic.setCreateTime(LocalDateTime.now());
        newMnemonic.setUpdateTime(LocalDateTime.now());
        newMnemonic.setDeleted(0);
        save(newMnemonic);
    }
    
    private String encryptMnemonic(String mnemonic) {
        // TODO: 实现加密逻辑，使用AES或其他加密算法
        // 这里暂时简单处理，实际应该使用加密
        return mnemonic;
    }
}
