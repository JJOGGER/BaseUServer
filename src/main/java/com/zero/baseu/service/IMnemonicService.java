package com.zero.baseu.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.zero.baseu.entity.Mnemonic;

public interface IMnemonicService extends IService<Mnemonic> {
    void importMnemonic(String mnemonic);
}
