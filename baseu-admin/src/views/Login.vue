<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h1>BaseU Admin</h1>
        <p>数字资产管理平台</p>
      </div>
      <el-form :model="loginForm" :rules="rules" ref="formRef" class="login-form">
        <el-form-item prop="account">
          <el-input v-model="loginForm.account" placeholder="手机号" prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="loginForm.password" type="password" placeholder="密码" prefix-icon="Lock" size="large" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" @click="handleLogin" :loading="loading" class="login-button">
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { authApi } from '@/api/auth'

const router = useRouter()
const formRef = ref()
const loading = ref(false)

const loginForm = reactive({
  account: '',
  password: ''
})

const rules = {
  account: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  await formRef.value.validate()
  loading.value = true
  
  try {
    const data = await authApi.login(loginForm)
    localStorage.setItem('token', data.token)
    ElMessage.success('登录成功')
    router.push('/')
  } catch (error) {
    ElMessage.error('登录失败，请检查账号密码')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--bg-primary) 0%, var(--bg-secondary) 100%);
}

.login-box {
  width: 400px;
  padding: 48px;
  background: var(--bg-secondary);
  border-radius: 16px;
  border: 1px solid var(--border-color);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-header h1 {
  font-size: 32px;
  font-weight: 700;
  color: var(--primary-color);
  margin-bottom: 8px;
}

.login-header p {
  color: var(--text-tertiary);
  font-size: 14px;
}

.login-form {
  margin-top: 24px;
}

.login-button {
  width: 100%;
  background: var(--primary-color);
  border: none;
  font-weight: 600;
}

.login-button:hover {
  background: var(--primary-hover);
}

:deep(.el-input__wrapper) {
  background: var(--bg-primary);
  border: 1px solid var(--border-color);
  box-shadow: none;
}

:deep(.el-input__wrapper:hover) {
  border-color: var(--border-hover);
}

:deep(.el-input__wrapper.is-focus) {
  border-color: var(--primary-color);
}

:deep(.el-input__inner) {
  color: var(--text-primary);
}

:deep(.el-input__inner::placeholder) {
  color: var(--text-tertiary);
}
</style>
