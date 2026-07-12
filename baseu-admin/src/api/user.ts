import request from './request'

export interface UserInfo {
  id: number
  phone: string
  username: string
  balance: number
  country: string
  createTime: string
}

export interface ChangePasswordRequest {
  oldPassword: string
  newPassword: string
}

export interface User {
  id?: number
  username: string
  email?: string
  phone: string
  passwordHash?: string
  salt?: string
  countryCode?: string
  dialCode?: string
  status?: number
}

export interface UserListResponse {
  records: User[]
  total: number
  current: number
  size: number
}

export const userApi = {
  // 获取用户信息
  getUserInfo: () => {
    return request.get<UserInfo>('/user/info')
  },

  // 修改密码
  changePassword: (data: ChangePasswordRequest) => {
    return request.put('/user/password', data)
  },

  // 管理员：获取用户列表
  getUserList: (params: { page: number; size: number; phone?: string }) => {
    return request.get<UserListResponse>('/user/admin/list', { params })
  },

  // 管理员：创建用户
  createUser: (data: User) => {
    return request.post('/user/admin/create', data)
  },

  // 管理员：更新用户
  updateUser: (data: User) => {
    return request.put('/user/admin/update', data)
  },

  // 管理员：删除用户
  deleteUser: (id: number) => {
    return request.delete(`/user/admin/delete/${id}`)
  }
}
