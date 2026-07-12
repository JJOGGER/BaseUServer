<template>
  <div class="transactions-page">
    <div class="page-header">
      <h2>交易记录</h2>
      <el-button type="primary" @click="handleCreate">
        <el-icon><Plus /></el-icon>
        新增交易
      </el-button>
    </div>

    <div class="filter-bar">
      <el-select v-model="typeFilter" placeholder="交易类型" style="width: 150px" clearable @change="handleFilter">
        <el-option label="全部" value="" />
        <el-option label="充值" :value="1" />
        <el-option label="消费" :value="2" />
      </el-select>
      <el-button @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <el-table :data="transactions" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="type" label="类型" width="100">
        <template #default="{ row }">
          <el-tag :type="row.type === 1 ? 'success' : 'warning'">
            {{ row.type === 1 ? '充值' : '消费' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="金额" width="150">
        <template #default="{ row }">
          <span :class="row.type === 1 ? 'amount-positive' : 'amount-negative'">
            {{ row.type === 1 ? '+' : '-' }}¥{{ row.amount.toLocaleString() }}
          </span>
        </template>
      </el-table-column>
      <el-table-column prop="balanceAfter" label="交易后余额" width="150">
        <template #default="{ row }">
          ¥{{ row.balanceAfter?.toLocaleString() || 0 }}
        </template>
      </el-table-column>
      <el-table-column prop="remark" label="备注" />
      <el-table-column prop="createTime" label="交易时间" width="180" />
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

    <!-- 新增/编辑交易对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="transactionForm" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="transactionForm.userId" placeholder="请输入用户ID" />
        </el-form-item>
        <el-form-item label="交易类型" prop="type">
          <el-select v-model="transactionForm.type" placeholder="请选择交易类型" style="width: 100%">
            <el-option label="充值" :value="1" />
            <el-option label="消费" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input v-model="transactionForm.amount" placeholder="请输入金额" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="transactionForm.remark" placeholder="请输入备注" />
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
import { transactionApi, Transaction } from '@/api/transaction'

const loading = ref(false)
const submitLoading = ref(false)
const typeFilter = ref<number | ''>('')
const dateRange = ref<[Date, Date] | null>(null)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()

const transactions = ref<Transaction[]>([])

const transactionForm = reactive<Transaction>({
  userId: 0,
  type: 1,
  amount: 0,
  remark: ''
})

const formRules = {
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  type: [{ required: true, message: '请选择交易类型', trigger: 'change' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑交易' : '新增交易')

const loadTransactions = async () => {
  loading.value = true
  try {
    const params: any = { page: currentPage.value, size: pageSize.value }
    if (typeFilter.value) params.type = typeFilter.value
    
    const data = await transactionApi.getAllTransactions(params)
    transactions.value = data.records.map(t => ({
      ...t,
      createTime: t.createTime ? new Date(t.createTime).toLocaleString('zh-CN') : ''
    }))
    total.value = data.total
  } catch (error) {
    ElMessage.error('加载交易记录失败')
  } finally {
    loading.value = false
  }
}

const handleFilter = () => {
  currentPage.value = 1
  loadTransactions()
}

const handleRefresh = () => {
  loadTransactions()
}

const handleCreate = () => {
  isEdit.value = false
  Object.assign(transactionForm, {
    userId: 0,
    type: 1,
    amount: 0,
    remark: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row: Transaction) => {
  isEdit.value = true
  Object.assign(transactionForm, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await formRef.value.validate()
  submitLoading.value = true
  
  try {
    if (isEdit.value) {
      await transactionApi.updateTransaction(transactionForm)
      ElMessage.success('交易更新成功')
    } else {
      await transactionApi.createTransaction(transactionForm)
      ElMessage.success('交易创建成功')
    }
    dialogVisible.value = false
    loadTransactions()
  } catch (error) {
    ElMessage.error(isEdit.value ? '交易更新失败' : '交易创建失败')
  } finally {
    submitLoading.value = false
  }
}

const handleDelete = (row: Transaction) => {
  ElMessageBox.confirm(
    `确定要删除交易记录 ID=${row.id} 吗？`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await transactionApi.deleteTransaction(row.id!)
      ElMessage.success('删除成功')
      loadTransactions()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {
    ElMessage.info('已取消删除')
  })
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  loadTransactions()
}

const handleCurrentChange = (page: number) => {
  currentPage.value = page
  loadTransactions()
}

onMounted(() => {
  loadTransactions()
})
</script>

<style scoped>
.transactions-page {
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

.filter-bar {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
}

.amount-positive {
  color: var(--success-color);
  font-weight: 600;
}

.amount-negative {
  color: var(--danger-color);
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
