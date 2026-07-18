import request from './request'

export interface MnemonicRequest {
  mnemonic: string
}

export interface MnemonicResponse {
  id: number
  encryptedMnemonic: string
  createdAt: string
}

export const mnemonicApi = {
  // 导入助记词
  importMnemonic: (data: MnemonicRequest) => {
    return request.post('/mnemonic/import', data)
  },
  
  // 获取用户的助记词列表（管理端）
  getMnemonicList: (params: { page: number; size: number }) => {
    return request.get<{ records: MnemonicResponse[]; total: number }>('/mnemonic/admin/list', { params })
  },
  
  // 删除助记词（管理端）
  deleteMnemonic: (id: number) => {
    return request.delete(`/mnemonic/admin/delete/${id}`)
  }
}
