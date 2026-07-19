package com.zero.baseu.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("mnemonic")
public class Mnemonic {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String encryptedMnemonic;
    
    /** 与 MetaObjectHandler 的 createTime 对齐，列名保持 V5 的 created_at */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    
    /** 与 MetaObjectHandler 的 updateTime 对齐，列名保持 V5 的 updated_at */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
}
