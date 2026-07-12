<template>
  <div class="recharge-page">
    <div class="page-header">
      <h2>充值管理</h2>
      <el-button type="primary" @click="handleCreate">
        <el-icon><Plus /></el-icon>
        新增充值
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
      <el-button @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <el-table :data="recharges" v-loading="loading" style="width: 100%">
      <el-table-column prop="id" label="订单ID" width="100" />
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="amount" label="充值金额" width="120">
        <template #default="{ row }">
          <span class="amount">¥{{ row.amount.toLocaleString() }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="paymentChannel" label="支付渠道" width="120">
        <template #default="{ row }">
          <el-tag>{{ row.paymentChannel || row.paymentMethod || '-' }}</el-tag>
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

    <!-- 新增/编辑充值对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="rechargeForm" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="rechargeForm.userId" placeholder="请输入用户ID" />
        </el-form-item>
        <el-form-item label="充值金额" prop="amount">
          <el-input v-model="rechargeForm.amount" placeholder="请输入充值金额" />
        </el-form-item>
        <el-form-item label="支付渠道" prop="paymentChannel">
          <el-input v-model="rechargeForm.paymentChannel" placeholder="如: alipay" />
        </el-form-item>
        <el-form-item label="支付方式" prop="paymentMethod">
          <el-input v-model="rechargeForm.paymentMethod" placeholder="如: 支付宝" />
        </el-form-item>
        <el-form-item label="订单状态" prop="status">
          <el-select v-model="rechargeForm.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="待支付" :value="0" />
            <el-option label="已支付" :value="1" />
            <el-option label="已取消" :value="2" />
            <el-option label="已失败" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="订单号" prop="orderNo">
          <el-input v-model="rechargeForm.orderNo" placeholder="请输入订单号" />
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
import { rechargeApi, Recharge } from '@/api/recharge'

const loading = ref(false)
const submitLoading = ref(false)
const statusFilter = ref<number | ''>('')
const dateRange = ref<[Date, Date] | null>(null)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()

const recharges = ref<Recharge[]>([])

const rechargeForm = reactive<Recharge>({
  userId: 0,
  amount: 0,
  paymentChannel: '',
  paymentMethod: '',
  status: 0,
  orderNo: ''
})

const formRules = {
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  amount: [{ required: true, message: '请输入充值金额', trigger: 'blur' }],
  status: [{ required: true, message: '请选择订单状态', trigger: 'change' }]
}

const dialogTitle = computed(() => isEdit.value ? '编辑充值' : '新增充值')

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
    
    const data = await rechargeApi.getAllRecharges(params)
    recharges.value = data.records.map(r => ({
      ...r,
      createTime: r.createTime ? new Date(r.createTime).toLocaleString('zh-CN') : ''
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

const handleCreate = () => {
  isEdit.value = false
  Object.assign(rechargeForm, {
    userId: 0,
    amount: 0,
    paymentChannel: '',
    paymentMethod: '',
    status: 0,
    orderNo: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row: Recharge) => {
  isEdit.value = true
  Object.assign(rechargeForm, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await formRef.value.validate()
  submitLoading.value = true
  
  try {
    if (isEdit.value) {
      await rechargeApi.updateRecharge(rechargeForm)
      ElMessage.success('充值记录更新成功')
    } else {
      await rechargeApi.createRechargeRecord(rechargeForm)
      ElMessage.success('充值记录创建成功')
    }
    dialogVisible.value = false
    loadRecharges()
  } catch (error) {
    ElMessage.error(isEdit.value ? '充值记录更新失败' : '充值记录创建失败')
  } finally {
    submitLoading.value = false
  }
}

const handleDelete = (row: Recharge) => {
  ElMessageBox.confirm(
    `确定要删除充值记录 ID=${row.id} 吗？`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await rechargeApi.deleteRecharge(row.id!)
      ElMessage.success('删除成功')
      loadRecharges()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {
    ElMessage.info('已取消删除')
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
