<template>
  <div class="transactions-page">
    <div class="page-header">
      <h2>交易记录</h2>
      <el-button type="primary" @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <div class="filter-bar">
      <el-select v-model="typeFilter" placeholder="交易类型" style="width: 150px" clearable @change="handleFilter">
        <el-option label="全部" value="" />
        <el-option label="充值" :value="1" />
        <el-option label="消费" :value="2" />
      </el-select>
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        style="width: 300px"
        @change="handleFilter"
      />
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
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="handleView(row)">详情</el-button>
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
import { ElMessage } from 'element-plus'
import { transactionApi } from '@/api/transaction'

const loading = ref(false)
const typeFilter = ref<number | ''>('')
const dateRange = ref<[Date, Date] | null>(null)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const transactions = ref([])

const loadTransactions = async () => {
  loading.value = true
  try {
    const params: any = { page: currentPage.value, size: pageSize.value }
    if (typeFilter.value) params.type = typeFilter.value
    
    const data = await transactionApi.getTransactionList(params)
    transactions.value = data.records.map(t => ({
      id: t.id,
      userId: t.userId,
      type: t.type,
      amount: t.amount,
      balanceAfter: t.balanceAfter,
      remark: t.remark,
      createTime: new Date(t.createTime).toLocaleString('zh-CN')
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

const handleView = (row: any) => {
  ElMessage.info(`交易详情: ID=${row.id}, 金额=${row.amount}, 备注=${row.remark}`)
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
