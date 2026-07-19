import request from './request'

export interface MnemonicResponse {
  id: number
  encryptedMnemonic: string
  createdAt: string
}

/** 管理端：助记词由客户端上传，后台仅查询/删除 */
export const mnemonicApi = {
  getMnemonicList: (params: { page: number; size: number }) => {
    return request.get<{ records: MnemonicResponse[]; total: number }>('/mnemonic/admin/list', { params })
  },

  deleteMnemonic: (id: number) => {
    return request.delete(`/mnemonic/admin/delete/${id}`)
  }
}
