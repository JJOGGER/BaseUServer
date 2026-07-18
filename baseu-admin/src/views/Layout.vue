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
          <el-menu-item index="/mnemonic">
            <el-icon><Key /></el-icon>
            <span>助记词管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      <el-container>
        <el-header class="header">
          <div class="header-left">
            <h3>{{ pageTitle }}</h3>
          </div>
          <div class="user-info" @click="handleLogout">
            <el-icon><User /></el-icon>
            <span>{{ userInfo.username || '管理员' }}</span>
            <el-icon><ArrowDown /></el-icon>
          </div>
        </el-header>
        <el-main class="main-content">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
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
    '/recharge': '充值管理',
    '/mnemonic': '助记词管理'
  }
  return titles[route.path] || '仪表盘'
})

const userInfo = ref({ username: '', email: '', phone: '' })

const loadUserInfo = async () => {
  try {
    const data = await userApi.getUserInfo()
    userInfo.value = data
  } catch (error) {
    console.error('获取用户信息失败', error)
  }
}

const handleLogout = () => {
  localStorage.removeItem('token')
  ElMessage.success('退出登录成功')
  router.push('/login')
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
