import { apiClient } from '#/lib/client'
import type { ApiResponse } from '#/types/api'
import type { CreatePlanInput, Plan, UpdatePlanInput } from '../plans-types'

export const plansApi = {
  getPlans: async (): Promise<Plan[]> => {
    const response = await apiClient.get<ApiResponse<Plan[]>>('/Plans')
    return response.data.data
  },

  getPlanById: async (id: number): Promise<Plan> => {
    const response = await apiClient.get<ApiResponse<Plan>>(`/Plans/${id}`)
    return response.data.data
  },

  createPlan: async (data: CreatePlanInput): Promise<Plan> => {
    const response = await apiClient.post<ApiResponse<Plan>>('/Plans', data)
    return response.data.data
  },

  updatePlan: async (id: number, data: UpdatePlanInput): Promise<Plan> => {
    const response = await apiClient.put<ApiResponse<Plan>>(`/Plans/${id}`, data)
    return response.data.data
  },

  activatePlan: async (id: number): Promise<void> => {
    await apiClient.patch(`/Plans/${id}/activate`)
  },

  deactivatePlan: async (id: number): Promise<void> => {
    await apiClient.patch(`/Plans/${id}/deactivate`)
  },

  deletePlan: async (id: number): Promise<void> => {
    await apiClient.delete(`/Plans/${id}`)
  },
}
