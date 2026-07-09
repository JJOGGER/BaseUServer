<template>
  <div class="users-page">
    <div class="page-header">
      <h2>用户管理</h2>
      <el-button type="primary" @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <div class="search-bar">
      <el-input
        v-model="searchQuery"
        placeholder="搜索手机号"
        prefix-icon="Search"
        style="width: 300px"
        @input="handleSearch"
      />
    </div>

    <el-table :data="users" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="phone" label="手机号" width="140" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="balance" label="余额" width="120">
        <template #default="{ row }">
          <span class="balance-amount">¥{{ row.balance?.toLocaleString() || 0 }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="country" label="国家" width="100" />
      <el-table-column prop="createTime" label="注册时间" width="180" />
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
          <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pagination">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { userApi } from '@/api/user'

const loading = ref(false)
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const users = ref([])

const loadUsers = async () => {
  loading.value = true
  try {
    // 注意：当前后端没有用户列表API，这里需要添加
    // 暂时使用模拟数据
    users.value = [
      { id: 1, phone: '13800138000', username: 'admin', balance: 100000, country: 'CN', createTime: '2024-01-15 10:30' }
    ]
    total.value = users.value.length
  } catch (error) {
    ElMessage.error('加载用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  loadUsers()
}

const handleRefresh = () => {
  loadUsers()
}

const handleView = async (row: any) => {
  try {
    const userInfo = await userApi.getUserInfo()
    ElMessage.info(`用户信息: ${userInfo.username}, 余额: ¥${userInfo.balance}`)
  } catch (error) {
    ElMessage.error('获取用户信息失败')
  }
}

const handleDelete = (row: any) => {
  ElMessageBox.confirm(
    `确定要删除用户 ${row.username} 吗？`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('删除成功')
    loadUsers()
  }).catch(() => {
    ElMessage.info('已取消删除')
  })
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  loadUsers()
}

const handleCurrentChange = (page: number) => {
  currentPage.value = page
  loadUsers()
}

onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.users-page {
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-header h2 {
  color: var(--text-primary);
  font-size: 24px;
  font-weight: 600;
}

.search-bar {
  margin-bottom: 24px;
}

.balance-amount {
  color: var(--primary-color);
  font-weight: 600;
}

.pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

:deep(.el-table) {
  background: transparent;
}

:deep(.el-table th) {
  background: var(--bg-tertiary);
  color: var(--text-secondary);
  border-color: var(--border-color);
}

:deep(.el-table td) {
  border-color: var(--border-color);
  color: var(--text-primary);
}

:deep(.el-table tr:hover > td) {
  background: var(--bg-tertiary);
}

:deep(.el-pagination) {
  --el-pagination-text-color: var(--text-secondary);
  --el-pagination-bg-color: transparent;
  --el-pagination-border-color: var(--border-color);
}

:deep(.el-pagination .el-pager li) {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
}

:deep(.el-pagination .el-pager li:hover) {
  background: var(--bg-tertiary);
  color: var(--text-primary);
}

:deep(.el-pagination .el-pager li.is-active) {
  background: var(--primary-color);
  color: white;
}
</style>
