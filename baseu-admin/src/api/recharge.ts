import request from './request'

export interface Recharge {
  id: number
  userId: number
  amount: number
  channel: string
  status: number
  orderNo: string
  createTime: string
}

export interface CreateRechargeRequest {
  amount: number
  channel: string
}

export const rechargeApi = {
  // 创建充值订单
  createRecharge: (data: CreateRechargeRequest) => {
    return request.post<{ orderNo: string; paymentUrl: string }>('/recharge/create', data)
  },

  // 查询充值记录
  getRechargeList: (params: { page: number; size: number; status?: number }) => {
    return request.get<{ records: Recharge[]; total: number }>('/recharge/list', { params })
  }
}
