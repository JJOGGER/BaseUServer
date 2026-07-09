import request from './request'

export interface LoginRequest {
  phone: string
  password: string
}

export interface RegisterRequest {
  phone: string
  code: string
  password: string
  username?: string
}

export interface LoginResponse {
  token: string
  refreshToken: string
  expiresIn: number
}

export const authApi = {
  // 发送验证码
  sendCode: (phone: string) => {
    return request.post('/auth/send-code', { phone })
  },

  // 用户注册
  register: (data: RegisterRequest) => {
    return request.post<LoginResponse>('/auth/register', data)
  },

  // 用户登录
  login: (data: LoginRequest) => {
    return request.post<LoginResponse>('/auth/login', data)
  },

  // 刷新Token
  refreshToken: (refreshToken: string) => {
    return request.post<LoginResponse>('/auth/refresh-token', {}, {
      headers: { Authorization: `Bearer ${refreshToken}` }
    })
  }
}
