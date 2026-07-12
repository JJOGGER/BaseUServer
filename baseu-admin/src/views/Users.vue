<template>
  <div class="users-page">
    <div class="page-header">
      <h2>用户管理</h2>
      <el-button type="primary" @click="handleCreate">
        <el-icon><Plus /></el-icon>
        新增用户
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
      <el-button @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <el-table :data="users" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="phone" label="手机号" width="140" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="email" label="邮箱" width="180" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'">
            {{ row.status === 1 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="注册时间" width="180" />
      <el-table-column label="操作" width="200">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
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

    <!-- 新增/编辑用户对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="userForm" :rules="formRules" ref="formRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="国家代码" prop="countryCode">
          <el-input v-model="userForm.countryCode" placeholder="如: CN" />
        </el-form-item>
        <el-form-item label="区号" prop="dialCode">
          <el-input v-model="userForm.dialCode" placeholder="如: +86" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-switch v-model="userForm.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { userApi, User } from '@/api/user'

const loading = ref(false)
const submitLoading = ref(false)
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()

const users = ref<User[]>([])

const userForm = reactive<User>({
  username: '',
  phone: '',
  email: '',
  countryCode: 'CN',
  dialCode: '+86',
  status: 1
})

const formRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑用户' : '新增用户')

const loadUsers = async () => {
  loading.value = true
  try {
    const data = await userApi.getUserList({ 
      page: currentPage.value, 
      size: pageSize.value,
      phone: searchQuery.value 
    })
    users.value = data.records
    total.value = data.total
  } catch (error) {
    ElMessage.error('加载用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadUsers()
}

const handleRefresh = () => {
  loadUsers()
}

const handleCreate = () => {
  isEdit.value = false
  Object.assign(userForm, {
    username: '',
    phone: '',
    email: '',
    countryCode: 'CN',
    dialCode: '+86',
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: User) => {
  isEdit.value = true
  Object.assign(userForm, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await formRef.value.validate()
  submitLoading.value = true
  
  try {
    if (isEdit.value) {
      await userApi.updateUser(userForm)
      ElMessage.success('用户更新成功')
    } else {
      await userApi.createUser(userForm)
      ElMessage.success('用户创建成功')
    }
    dialogVisible.value = false
    loadUsers()
  } catch (error) {
    ElMessage.error(isEdit.value ? '用户更新失败' : '用户创建失败')
  } finally {
    submitLoading.value = false
  }
}

const handleDelete = (row: User) => {
  ElMessageBox.confirm(
    `确定要删除用户 ${row.username} 吗？`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await userApi.deleteUser(row.id!)
      ElMessage.success('删除成功')
      loadUsers()
    } catch (error) {
      ElMessage.error('删除失败')
    }
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
  background: white;
  border: 1px solid var(--border-color);
}

:deep(.el-table th) {
  background: var(--bg-tertiary);
  color: var(--text-primary);
  border-color: var(--border-color);
}

:deep(.el-table td) {
  border-color: var(--border-color);
  color: var(--text-primary);
  background: white;
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
  background: white;
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
