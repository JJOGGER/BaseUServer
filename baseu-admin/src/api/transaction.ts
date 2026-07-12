import request from './request'

export interface Transaction {
  id?: number
  userId: number
  type: number
  amount: number
  balanceAfter?: number
  remark?: string
  createTime?: string
}

export interface TransactionListResponse {
  records: Transaction[]
  total: number
  current: number
  size: number
}

export const transactionApi = {
  // 查询交易记录
  getTransactionList: (params: { page: number; size: number; type?: number }) => {
    return request.get<TransactionListResponse>('/transaction/list', { params })
  },

  // 管理员：获取所有交易记录
  getAllTransactions: (params: { page: number; size: number; type?: number }) => {
    return request.get<TransactionListResponse>('/transaction/admin/list', { params })
  },

  // 管理员：创建交易记录
  createTransaction: (data: Transaction) => {
    return request.post('/transaction/admin/create', data)
  },

  // 管理员：更新交易记录
  updateTransaction: (data: Transaction) => {
    return request.put('/transaction/admin/update', data)
  },

  // 管理员：删除交易记录
  deleteTransaction: (id: number) => {
    return request.delete(`/transaction/admin/delete/${id}`)
  }
}
