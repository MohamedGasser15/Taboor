import { apiClient } from '#/lib/client'
import type { ApiResponse, LoginRequest, LoginResponse } from '../auth-types'

export const authApi = {
  login: async (credentials: LoginRequest): Promise<LoginResponse> => {
    const response = await apiClient.post<ApiResponse<LoginResponse>>(
      '/auth/login',
      credentials,
      { skipAuthRefresh: true },
    )

    return response.data.data
  },

  logout: async (): Promise<void> => {
    await apiClient.post('/auth/revoke', undefined, { skipAuthRefresh: true })
  },
}
