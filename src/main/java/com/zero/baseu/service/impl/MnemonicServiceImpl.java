package com.zero.baseu.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.zero.baseu.entity.Mnemonic;
import com.zero.baseu.mapper.MnemonicMapper;
import com.zero.baseu.service.IMnemonicService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MnemonicServiceImpl extends ServiceImpl<MnemonicMapper, Mnemonic> implements IMnemonicService {
    
    @Override
    @Transactional
    public void importMnemonic(String mnemonic) {
        // 创建新助记词记录
        Mnemonic newMnemonic = new Mnemonic();
        newMnemonic.setEncryptedMnemonic(encryptMnemonic(mnemonic));
        save(newMnemonic);
    }
    
    private String encryptMnemonic(String mnemonic) {
        // TODO: 实现加密逻辑，使用AES或其他加密算法
        // 这里暂时简单处理，实际应该使用加密
        return mnemonic;
    }
}
