<template>
  <div class="mnemonic-page">
    <div class="page-header">
      <h2>助记词管理</h2>
      <el-button type="primary" @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>
    
    <el-table :data="mnemonicList" stripe v-loading="loading" class="data-table">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="encryptedMnemonic" label="加密助记词" show-overflow-tooltip />
      <el-table-column prop="createdAt" label="创建时间" width="180" />
      <el-table-column label="操作" width="120" fixed="right">
        <template #default="{ row }">
          <el-button type="danger" size="small" @click="handleDelete(row)">
            删除
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
import { Refresh } from '@element-plus/icons-vue'
import { mnemonicApi, MnemonicResponse } from '@/api/mnemonic'

const loading = ref(false)
const mnemonicList = ref<MnemonicResponse[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const loadMnemonics = async () => {
  loading.value = true
  try {
    const data = await mnemonicApi.getMnemonicList({
      page: currentPage.value,
      size: pageSize.value
    })
    mnemonicList.value = data.records
    total.value = data.total
  } catch (error) {
    ElMessage.error('加载助记词列表失败')
  } finally {
    loading.value = false
  }
}

const handleRefresh = () => {
  loadMnemonics()
}

const handleDelete = async (row: MnemonicResponse) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除ID为 ${row.id} 的助记词吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await mnemonicApi.deleteMnemonic(row.id)
    ElMessage.success('删除成功')
    loadMnemonics()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSizeChange = (val: number) => {
  pageSize.value = val
  loadMnemonics()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  loadMnemonics()
}

onMounted(() => {
  loadMnemonics()
})
</script>

<style scoped>
.mnemonic-page {
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: var(--text-primary);
}

.data-table {
  background: var(--bg-secondary);
  border-radius: 8px;
  overflow: hidden;
}

.pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

:deep(.el-table) {
  background: var(--bg-secondary);
}

:deep(.el-table th) {
  background: var(--bg-primary);
  color: var(--text-primary);
  border-color: var(--border-color);
}

:deep(.el-table td) {
  border-color: var(--border-color);
}

:deep(.el-table tr:hover > td) {
  background: var(--bg-hover);
}

:deep(.el-table__body tr) {
  color: var(--text-primary);
}

:deep(.el-pagination) {
  color: var(--text-primary);
}

:deep(.el-pagination .el-pager li) {
  background: var(--bg-secondary);
  border-color: var(--border-color);
  color: var(--text-primary);
}

:deep(.el-pagination .el-pager li:hover) {
  color: var(--primary-color);
}

:deep(.el-pagination .el-pager li.is-active) {
  background: var(--primary-color);
  color: white;
}
</style>
