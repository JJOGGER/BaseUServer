import request from './request'

export interface Transaction {
  id: number
  userId: number
  type: number
  amount: number
  balanceAfter: number
  remark: string
  createTime: string
}

export const transactionApi = {
  // 查询交易记录
  getTransactionList: (params: { page: number; size: number; type?: number }) => {
    return request.get<{ records: Transaction[]; total: number }>('/transaction/list', { params })
  }
}
