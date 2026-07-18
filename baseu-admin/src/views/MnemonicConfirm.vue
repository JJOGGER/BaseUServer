<template>
  <div class="mnemonic-container">
    <div class="mnemonic-box">
      <div class="mnemonic-header">
        <h1>确认助记词</h1>
        <p>请确认您的助记词是否正确</p>
      </div>
      
      <div class="mnemonic-display">
        <div class="mnemonic-words">
          <span 
            v-for="(word, index) in mnemonicWords" 
            :key="index"
            class="mnemonic-word"
          >
            {{ word }}
          </span>
        </div>
      </div>
      
      <el-form :model="form" :rules="rules" ref="formRef" class="mnemonic-form">
        <el-form-item prop="confirmed">
          <el-checkbox v-model="form.confirmed" size="large">
            我已确认助记词正确无误
          </el-checkbox>
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            size="large" 
            @click="handleConfirm" 
            :loading="loading"
            class="confirm-button"
          >
            确认导入
          </el-button>
        </el-form-item>
        
        <el-form-item>
          <el-button 
            size="large" 
            @click="handleBack"
            class="back-button"
          >
            返回修改
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="mnemonic-tips">
        <el-alert
          title="重要提示"
          type="error"
          :closable="false"
          show-icon
        >
          <ul>
            <li>请仔细核对每个单词，确保拼写正确</li>
            <li>助记词顺序错误将导致无法恢复钱包</li>
            <li>确认后将提交到服务器进行加密存储</li>
          </ul>
        </el-alert>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { mnemonicApi } from '@/api/mnemonic'

const router = useRouter()
const formRef = ref()
const loading = ref(false)
const mnemonic = ref('')

const form = reactive({
  confirmed: false
})

const rules = {
  confirmed: [
    { 
      validator: (rule: any, value: boolean, callback: any) => {
        if (!value) {
          callback(new Error('请确认助记词正确'))
          return)
        }
        callback()
      },
      trigger: 'change'
    }
  ]
}

const mnemonicWords = computed(() => {
  if (!mnemonic.value) return []
  return mnemonic.value.trim().split(/\s+/)
})

onMounted(() => {
  // 从临时存储中获取助记词
  const tempMnemonic = sessionStorage.getItem('tempMnemonic')
  if (!tempMnemonic) {
    ElMessage.error('未找到助记词，请重新输入')
    router.push('/mnemonic-input')
    return
  }
  mnemonic.value = tempMnemonic
})

const handleConfirm = async () => {
  await formRef.value.validate()
  
  loading.value = true
  
  try {
    // 提交助记词到服务器
    await mnemonicApi.importMnemonic({
      mnemonic: mnemonic.value
    })
    
    ElMessage.success('助记词导入成功')
    
    // 清除临时存储
    sessionStorage.removeItem('tempMnemonic')
    
    // 跳转到首页或其他页面
    router.push('/')
  } catch (error) {
    ElMessage.error('助记词导入失败，请重试')
  } finally {
    loading.value = false
  }
}

const handleBack = () => {
  router.push('/mnemonic-input')
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
  max-width: 600px;
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

.mnemonic-display {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
}

.mnemonic-words {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
}

.mnemonic-word {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 14px;
  color: var(--text-primary);
  font-weight: 500;
}

.mnemonic-form {
  margin-top: 24px;
}

.confirm-button {
  width: 100%;
  background: var(--primary-color);
  border: none;
  font-weight: 600;
}

.confirm-button:hover {
  background: var(--primary-hover);
}

.back-button {
  width: 100%;
  margin-top: 12px;
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

:deep(.el-checkbox__label) {
  color: var(--text-primary);
}
</style>
