<template>
  <div class="mnemonic-container">
    <div class="mnemonic-box">
      <div class="mnemonic-header">
        <h1>导入钱包</h1>
        <p>请输入您的助记词以恢复钱包</p>
      </div>
      
      <el-form :model="form" :rules="rules" ref="formRef" class="mnemonic-form">
        <el-form-item prop="mnemonic">
          <el-input
            v-model="form.mnemonic"
            type="textarea"
            :rows="6"
            placeholder="请输入12或24位助记词，用空格分隔"
            class="mnemonic-textarea"
          />
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            size="large" 
            @click="handleNext" 
            :loading="loading"
            class="next-button"
          >
            下一步
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="mnemonic-tips">
        <el-alert
          title="安全提示"
          type="warning"
          :closable="false"
          show-icon
        >
          <ul>
            <li>助记词是恢复钱包的唯一凭证，请妥善保管</li>
            <li>不要将助记词告诉任何人或截图保存</li>
            <li>确保在安全的环境下输入助记词</li>
          </ul>
        </el-alert>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const formRef = ref()
const loading = ref(false)

const form = reactive({
  mnemonic: ''
})

const rules = {
  mnemonic: [
    { required: true, message: '请输入助记词', trigger: 'blur' },
    {
      validator: (rule: any, value: string, callback: any) => {
        if (!value) {
          callback(new Error('请输入助记词'))
          return)
        }
        
        const words = value.trim().split(/\s+/)
        if (words.length !== 12 && words.length !== 24) {
          callback(new Error('助记词必须是12或24位'))
          return)
        }
        
        callback()
      },
      trigger: 'blur'
    }
  ]
}

const handleNext = async () => {
  await formRef.value.validate()
  
  // 将助记词存储到临时状态
  sessionStorage.setItem('tempMnemonic', form.mnemonic)
  
  // 跳转到确认页面
  router.push('/mnemonic-confirm')
}
</script>

<style scoped>
.mnemonic-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--bg-primary) 0%, var(--bg-secondary) 100%);
  padding: 20px;
}

.mnemonic-box {
  width: 100%;
  max-width: 500px;
  padding: 48px;
  background: var(--bg-secondary);
  border-radius: 16px;
  border: 1px solid var(--border-color);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.mnemonic-header {
  text-align: center;
  margin-bottom: 32px;
}

.mnemonic-header h1 {
  font-size: 28px;
  font-weight: 700;
  color: var(--primary-color);
  margin-bottom: 8px;
}

.mnemonic-header p {
  color: var(--text-tertiary);
  font-size: 14px;
}

.mnemonic-form {
  margin-top: 24px;
}

.mnemonic-textarea {
  font-family: 'Courier New', monospace;
  font-size: 14px;
}

.next-button {
  width: 100%;
  background: var(--primary-color);
  border: none;
  font-weight: 600;
  margin-top: 16px;
}

.next-button:hover {
  background: var(--primary-hover);
}

.mnemonic-tips {
  margin-top: 24px;
}

.mnemonic-tips ul {
  margin: 8px 0 0 0;
  padding-left: 20px;
}

.mnemonic-tips li {
  color: var(--text-secondary);
  font-size: 13px;
  line-height: 1.6;
}

:deep(.el-textarea__inner) {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
}

:deep(.el-textarea__inner::placeholder) {
  color: var(--text-tertiary);
}

:deep(.el-textarea__inner:focus) {
  border-color: var(--primary-color);
}
</style>
