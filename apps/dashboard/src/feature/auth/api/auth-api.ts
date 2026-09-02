import { apiClient } from '#/lib/client'
import type { ApiResponse } from '#/types/api'
import type { LoginRequest, LoginResponse } from '../auth-types'

export const authApi = {
  login: async (credentials: LoginRequest): Promise<LoginResponse> => {
    const response = await apiClient.post<ApiResponse<LoginResponse>>(
      '/Auth/login',
      credentials,
      { skipAuthRefresh: true },
    )

    return response.data.data
  },

  logout: async (): Promise<void> => {
    await apiClient.post('/Auth/logout')
  },
}
