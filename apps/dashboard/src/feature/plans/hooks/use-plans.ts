import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { plansApi } from '../api/plans-api'
import type { CreatePlanInput, UpdatePlanInput } from '../plans-types'

export const PLANS_QUERY_KEY = ['plans'] as const

export function usePlans() {
  return useQuery({
    queryKey: PLANS_QUERY_KEY,
    queryFn: () => plansApi.getPlans(),
  })
}

export function usePlan(id: number) {
  return useQuery({
    queryKey: [...PLANS_QUERY_KEY, id],
    queryFn: () => plansApi.getPlanById(id),
    enabled: Number.isInteger(id) && id > 0,
  })
}

export function useCreatePlan() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: CreatePlanInput) => plansApi.createPlan(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
    },
  })
}

export function useUpdatePlan() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdatePlanInput }) =>
      plansApi.updatePlan(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
    },
  })
}

export function useActivatePlan() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => plansApi.activatePlan(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
    },
  })
}

export function useDeactivatePlan() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => plansApi.deactivatePlan(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
    },
  })
}

export function useDeletePlan() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (id: number) => plansApi.deletePlan(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
    },
  })
}
