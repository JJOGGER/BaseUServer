<template>
  <div class="dashboard">
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon :size="32"><User /></el-icon>
        </div>
        <div class="stat-content">
          <h3>总用户数</h3>
          <p class="stat-number">{{ stats.totalUsers }}</p>
          <span class="stat-trend positive">+12.5%</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon :size="32"><List /></el-icon>
        </div>
        <div class="stat-content">
          <h3>今日交易</h3>
          <p class="stat-number">{{ stats.todayTransactions }}</p>
          <span class="stat-trend positive">+8.2%</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon :size="32"><Wallet /></el-icon>
        </div>
        <div class="stat-content">
          <h3>充值总额</h3>
          <p class="stat-number">¥{{ stats.totalRecharge.toLocaleString() }}</p>
          <span class="stat-trend positive">+15.3%</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">
          <el-icon :size="32"><DataLine /></el-icon>
        </div>
        <div class="stat-content">
          <h3>活跃用户</h3>
          <p class="stat-number">{{ stats.activeUsers }}</p>
          <span class="stat-trend negative">-2.1%</span>
        </div>
      </div>
    </div>

    <div class="charts-section">
      <div class="chart-card">
        <h3>交易趋势</h3>
        <div class="chart-placeholder">
          <el-icon :size="64"><TrendCharts /></el-icon>
          <p>交易数据可视化图表</p>
        </div>
      </div>
      <div class="chart-card">
        <h3>用户增长</h3>
        <div class="chart-placeholder">
          <el-icon :size="64"><DataAnalysis /></el-icon>
          <p>用户增长趋势图表</p>
        </div>
      </div>
    </div>

    <div class="recent-section">
      <div class="recent-card">
        <h3>最近交易</h3>
        <el-table :data="recentTransactions" style="width: 100%">
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="row.type === 1 ? 'success' : 'warning'">
                {{ row.type === 1 ? '充值' : '消费' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="120">
            <template #default="{ row }">
              <span :class="row.type === 1 ? 'amount-positive' : 'amount-negative'">
                {{ row.type === 1 ? '+' : '-' }}¥{{ row.amount }}
              </span>
            </template>
          </el-table-column>
          <el-table-column prop="time" label="时间" />
        </el-table>
      </div>
      <div class="recent-card">
        <h3>最新用户</h3>
        <el-table :data="recentUsers" style="width: 100%">
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="phone" label="手机号" width="140" />
          <el-table-column prop="balance" label="余额" width="120">
            <template #default="{ row }">
              ¥{{ row.balance.toLocaleString() }}
            </template>
          </el-table-column>
          <el-table-column prop="registerTime" label="注册时间" />
        </el-table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { userApi } from '@/api/user'
import { transactionApi } from '@/api/transaction'
import { rechargeApi } from '@/api/recharge'

const loading = ref(false)
const stats = ref({
  totalUsers: 0,
  todayTransactions: 0,
  totalRecharge: 0,
  activeUsers: 0
})

const recentTransactions = ref([])
const recentUsers = ref([])

const loadDashboardData = async () => {
  loading.value = true
  try {
    // 获取交易记录
    const transactionData = await transactionApi.getTransactionList({ page: 1, size: 5 })
    recentTransactions.value = transactionData.records.map(t => ({
      id: t.id,
      type: t.type,
      amount: t.amount,
      time: new Date(t.createTime).toLocaleString('zh-CN')
    }))

    // 获取充值记录
    const rechargeData = await rechargeApi.getRechargeList({ page: 1, size: 5 })
    stats.value.totalRecharge = rechargeData.records.reduce((sum, r) => sum + (r.status === 2 ? r.amount : 0), 0)
    
    // 模拟统计数据（实际应该从专门的统计API获取）
    stats.value.totalUsers = 1 // 当前只有管理员
    stats.value.todayTransactions = transactionData.records.length
    stats.value.activeUsers = 1

  } catch (error) {
    console.error('加载数据失败', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
.dashboard {
  padding: 24px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s;
}

.stat-card:hover {
  border-color: var(--border-hover);
  transform: translateY(-2px);
}

.stat-icon {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.2) 0%, rgba(139, 92, 246, 0.1) 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--primary-color);
}

.stat-content h3 {
  color: var(--text-tertiary);
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 8px;
}

.stat-number {
  color: var(--text-primary);
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 4px;
}

.stat-trend {
  font-size: 12px;
  font-weight: 600;
}

.stat-trend.positive {
  color: var(--success-color);
}

.stat-trend.negative {
  color: var(--danger-color);
}

.charts-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.chart-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 24px;
}

.chart-card h3 {
  color: var(--text-primary);
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
}

.chart-placeholder {
  height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--text-tertiary);
  gap: 12px;
}

.recent-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
}

.recent-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 24px;
}

.recent-card h3 {
  color: var(--text-primary);
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
}

.amount-positive {
  color: var(--success-color);
  font-weight: 600;
}

.amount-negative {
  color: var(--danger-color);
  font-weight: 600;
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
</style>
