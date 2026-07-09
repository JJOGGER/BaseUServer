<template>
  <div class="layout-container">
    <el-container>
      <el-aside width="240px" class="sidebar">
        <div class="logo-section">
          <h2>BaseU Admin</h2>
          <p>数字资产管理平台</p>
        </div>
        <el-menu
          :default-active="activeMenu"
          background-color="transparent"
          router
        >
          <el-menu-item index="/">
            <el-icon><DataLine /></el-icon>
            <span>仪表盘</span>
          </el-menu-item>
          <el-menu-item index="/users">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/transactions">
            <el-icon><List /></el-icon>
            <span>交易记录</span>
          </el-menu-item>
          <el-menu-item index="/recharge">
            <el-icon><Wallet /></el-icon>
            <span>充值管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-container>
        <el-header class="header">
          <div class="header-left">
            <h3>{{ pageTitle }}</h3>
          </div>
          <el-dropdown @command="handleCommand">
            <div class="user-info">
              <el-icon><User /></el-icon>
              <span>{{ userInfo.username || '管理员' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>
                  个人信息
                </el-dropdown-item>
                <el-dropdown-item command="password">
                  <el-icon><Lock /></el-icon>
                  修改密码
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </el-header>
        <el-main class="main-content">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
  
  <!-- 修改密码对话框 -->
  <el-dialog v-model="passwordDialogVisible" title="修改密码" width="400px">
    <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="80px">
      <el-form-item label="原密码" prop="oldPassword">
        <el-input v-model="passwordForm.oldPassword" type="password" show-password />
      </el-form-item>
      <el-form-item label="新密码" prop="newPassword">
        <el-input v-model="passwordForm.newPassword" type="password" show-password />
      </el-form-item>
      <el-form-item label="确认密码" prop="confirmPassword">
        <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="passwordDialogVisible = false">取消</el-button>
      <el-button type="primary" @click="handleChangePassword" :loading="passwordLoading">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { userApi } from '@/api/user'

const router = useRouter()
const route = useRoute()

const activeMenu = computed(() => route.path)

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/': '仪表盘',
    '/users': '用户管理',
    '/transactions': '交易记录',
    '/recharge': '充值管理'
  }
  return titles[route.path] || '仪表盘'
})

const userInfo = ref({ username: '', email: '', phone: '' })
const passwordDialogVisible = ref(false)
const passwordLoading = ref(false)
const passwordFormRef = ref()

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule: any, value: string, callback: any) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]

const loadUserInfo = async () => {
  try {
    const data = await userApi.getUserInfo()
    userInfo.value = data
  } catch (error) {
    console.error('获取用户信息失败', error)
  }
}

const handleChangePassword = async () => {
  await passwordFormRef.value.validate()
  passwordLoading.value = true
  
  try {
    await userApi.changePassword({
      oldPassword: passwordForm.oldPassword,
      newPassword: passwordForm.newPassword
    })
    ElMessage.success('密码修改成功')
    passwordDialogVisible.value = false
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (error) {
    ElMessage.error('密码修改失败，请检查原密码')
  } finally {
    passwordLoading.value = false
  }
}

const handleCommand = (command: string) => {
  if (command === 'logout') {
    localStorage.removeItem('token')
    ElMessage.success('退出登录成功')
    router.push('/login')
  } else if (command === 'password') {
    passwordDialogVisible.value = true
  } else if (command === 'profile') {
    ElMessage.info('个人信息功能开发中')
  }
}

onMounted(() => {
  loadUserInfo()
})
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.sidebar {
  background: var(--bg-secondary);
  border-right: 1px solid var(--border-color);
}

.logo-section {
  padding: 24px;
  border-bottom: 1px solid var(--border-color);
}

.logo-section h2 {
  color: var(--primary-color);
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 4px;
}

.logo-section p {
  color: var(--text-tertiary);
  font-size: 12px;
}

.el-menu {
  border: none;
}

.el-menu-item {
  margin: 4px 12px;
  border-radius: 8px;
  color: var(--text-secondary);
}

.el-menu-item:hover {
  background: var(--bg-tertiary) !important;
  color: var(--text-primary);
}

.el-menu-item.is-active {
  background: var(--primary-color) !important;
  color: white;
}

.header {
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
}

.header-left h3 {
  color: var(--text-primary);
  font-size: 18px;
  font-weight: 600;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.3s;
}

.user-info:hover {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

.main-content {
  background: var(--bg-primary);
  padding: 24px;
}
</style>
