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

export const userApi = {
  // 获取用户信息
  getUserInfo: () => {
    return request.get<UserInfo>('/user/info')
  },

  // 修改密码
  changePassword: (data: ChangePasswordRequest) => {
    return request.put('/user/password', data)
  }
}
