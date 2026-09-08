import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { toast } from '@/components/ui/toast'
import { useOptimisticDelete } from '@/hooks/use-optimistic-delete'
import type { AxiosError } from 'axios'
import { useTranslation } from 'react-i18next'
import { plansApi } from '../api/plans-api'
import type { CreatePlanInput, Plan, UpdatePlanInput } from '../plans-types'

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
  const { t } = useTranslation('plans')

  return useMutation({
    mutationFn: (data: CreatePlanInput) => plansApi.createPlan(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
      toast.add({
        title: t('toasts.created'),
        type: 'success',
      })
    },
    onError: (error) => {
      const err = error as AxiosError<{ message?: string; errors?: string[] }>
      const msg =
        err.response?.data.errors?.[0] ??
        err.response?.data.message ??
        t('form.saveError')
      toast.add({
        title: t('form.saveError'),
        description: msg,
        type: 'error',
      })
    },
  })
}

export function useUpdatePlan() {
  const queryClient = useQueryClient()
  const { t } = useTranslation('plans')

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdatePlanInput }) =>
      plansApi.updatePlan(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY })
      toast.add({
        title: t('toasts.updated'),
        type: 'success',
      })
    },
    onError: (error) => {
      const err = error as AxiosError<{ message?: string; errors?: string[] }>
      const msg =
        err.response?.data.errors?.[0] ??
        err.response?.data.message ??
        t('form.saveError')
      toast.add({
        title: t('form.saveError'),
        description: msg,
        type: 'error',
      })
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

export function useTogglePlanStatus() {
  const activatePlan = useActivatePlan()
  const deactivatePlan = useDeactivatePlan()
  const { t } = useTranslation('plans')

  const isToggling = activatePlan.isPending || deactivatePlan.isPending

  const toggleStatus = (plan: Plan) => {
    if (plan.isActive) {
      deactivatePlan.mutate(plan.id, {
        onSuccess: () => {
          toast.add({
            title: t('toasts.deactivated'),
            type: 'success',
          })
        },
        onError: (error) => {
          const err = error as AxiosError<{
            message?: string
            errors?: string[]
          }>
          const msg =
            err.response?.data.errors?.[0] ??
            err.response?.data.message ??
            t('form.saveError')
          toast.add({
            title: t('form.saveError'),
            description: msg,
            type: 'error',
          })
        },
      })
    } else {
      activatePlan.mutate(plan.id, {
        onSuccess: () => {
          toast.add({
            title: t('toasts.activated'),
            type: 'success',
          })
        },
        onError: (error) => {
          const err = error as AxiosError<{
            message?: string
            errors?: string[]
          }>
          const msg =
            err.response?.data.errors?.[0] ??
            err.response?.data.message ??
            t('form.saveError')
          toast.add({
            title: t('form.saveError'),
            description: msg,
            type: 'error',
          })
        },
      })
    }
  }

  return {
    toggleStatus,
    isToggling,
  }
}

export function useDeletePlanWithUndo() {
  const { t } = useTranslation('plans')

  return useOptimisticDelete<Plan, number>({
    queryKey: PLANS_QUERY_KEY,
    deleteFn: (id) => plansApi.deletePlan(id),
    messages: {
      deleted: t('toasts.deleted'),
      undo: t('toasts.undo'),
      restored: t('toasts.restored'),
      errorTitle: t('toasts.deleteError'),
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
