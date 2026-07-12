import request from './request'

export interface Recharge {
  id?: number
  userId: number
  amount: number
  paymentChannel?: string
  paymentMethod?: string
  status: number
  orderNo?: string
  createTime?: string
}

export interface CreateRechargeRequest {
  amount: number
  channel: string
}

export interface RechargeListResponse {
  records: Recharge[]
  total: number
  current: number
  size: number
}

export const rechargeApi = {
  // 创建充值订单
  createRecharge: (data: CreateRechargeRequest) => {
    return request.post<{ orderNo: string; paymentUrl: string }>('/recharge/create', data)
  },

  // 查询充值记录
  getRechargeList: (params: { page: number; size: number; status?: number }) => {
    return request.get<RechargeListResponse>('/recharge/list', { params })
  },

  // 管理员：获取所有充值记录
  getAllRecharges: (params: { page: number; size: number; status?: number }) => {
    return request.get<RechargeListResponse>('/recharge/admin/list', { params })
  },

  // 管理员：创建充值记录
  createRechargeRecord: (data: Recharge) => {
    return request.post('/recharge/admin/create', data)
  },

  // 管理员：更新充值记录
  updateRecharge: (data: Recharge) => {
    return request.put('/recharge/admin/update', data)
  },

  // 管理员：删除充值记录
  deleteRecharge: (id: number) => {
    return request.delete(`/recharge/admin/delete/${id}`)
  }
}
