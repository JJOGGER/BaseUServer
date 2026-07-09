<template>
  <div class="recharge-page">
    <div class="page-header">
      <h2>充值管理</h2>
      <el-button type="primary" @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <div class="filter-bar">
      <el-select v-model="statusFilter" placeholder="订单状态" style="width: 150px" clearable @change="handleFilter">
        <el-option label="全部" value="" />
        <el-option label="待支付" :value="0" />
        <el-option label="已支付" :value="1" />
        <el-option label="已取消" :value="2" />
        <el-option label="已失败" :value="3" />
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

    <el-table :data="recharges" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="订单ID" width="100" />
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="amount" label="充值金额" width="120">
        <template #default="{ row }">
          <span class="amount">¥{{ row.amount.toLocaleString() }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="channel" label="支付渠道" width="100">
        <template #default="{ row }">
          <el-tag>{{ row.channel }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)">
            {{ getStatusText(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="orderNo" label="订单号" width="180" />
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="handleView(row)">详情</el-button>
          <el-button 
            v-if="row.status === 0" 
            type="danger" 
            size="small" 
            @click="handleCancel(row)"
          >
            取消
          </el-button>
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
import { rechargeApi } from '@/api/recharge'

const loading = ref(false)
const statusFilter = ref<number | ''>('')
const dateRange = ref<[Date, Date] | null>(null)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const recharges = ref([])

const getStatusType = (status: number) => {
  const types: Record<number, any> = {
    0: 'warning',
    1: 'success',
    2: 'info',
    3: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status: number) => {
  const texts: Record<number, string> = {
    0: '待支付',
    1: '已支付',
    2: '已取消',
    3: '已失败'
  }
  return texts[status] || '未知'
}

const loadRecharges = async () => {
  loading.value = true
  try {
    const params: any = { page: currentPage.value, size: pageSize.value }
    if (statusFilter.value) params.status = statusFilter.value
    
    const data = await rechargeApi.getRechargeList(params)
    recharges.value = data.records.map(r => ({
      id: r.id,
      userId: r.userId,
      amount: r.amount,
      channel: r.paymentChannel || r.paymentMethod,
      status: r.status,
      orderNo: r.orderNo,
      createTime: new Date(r.createTime).toLocaleString('zh-CN')
    }))
    total.value = data.total
  } catch (error) {
    ElMessage.error('加载充值记录失败')
  } finally {
    loading.value = false
  }
}

const handleFilter = () => {
  currentPage.value = 1
  loadRecharges()
}

const handleRefresh = () => {
  loadRecharges()
}

const handleView = (row: any) => {
  ElMessage.info(`订单详情: ${row.orderNo}, 金额: ¥${row.amount}`)
}

const handleCancel = (row: any) => {
  ElMessageBox.confirm(
    `确定要取消订单 ${row.orderNo} 吗？`,
    '确认取消',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('订单已取消')
    loadRecharges()
  }).catch(() => {
    ElMessage.info('已取消操作')
  })
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  loadRecharges()
}

const handleCurrentChange = (page: number) => {
  currentPage.value = page
  loadRecharges()
}

onMounted(() => {
  loadRecharges()
})
</script>

<style scoped>
.recharge-page {
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

.amount {
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
