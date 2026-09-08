import { useMutation, useQueryClient } from '@tanstack/react-query'
import { toast } from '@/components/ui/toast'
import type { AxiosError } from 'axios'
import { useRef } from 'react'

export interface OptimisticDeleteMessages {
  deleted: string
  undo: string
  restored: string
  errorTitle: string
  fallbackError?: string
}

export interface UseOptimisticDeleteOptions<TId = number | string> {
  queryKey: readonly unknown[]
  deleteFn: (id: TId) => Promise<unknown>
  messages: OptimisticDeleteMessages
  delayMs?: number
}

export function useOptimisticDelete<
  TItem extends { id: TId },
  TId = number | string,
>({
  queryKey,
  deleteFn,
  messages,
  delayMs = 5000,
}: UseOptimisticDeleteOptions<TId>) {
  const queryClient = useQueryClient()
  const pendingTimeoutsRef = useRef<Map<TId, ReturnType<typeof setTimeout>>>(
    new Map(),
  )

  const deleteMutation = useMutation({
    mutationFn: deleteFn,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey })
    },
  })

  const deleteWithUndo = (item: TItem) => {
    const itemId = item.id

    // Cancel any existing pending timeout for this item
    const existingTimeout = pendingTimeoutsRef.current.get(itemId)
    if (existingTimeout) {
      clearTimeout(existingTimeout)
      pendingTimeoutsRef.current.delete(itemId)
    }

    // Snapshot previous cache state
    const previousItems = queryClient.getQueryData<TItem[]>(queryKey)

    // Optimistically remove the item from query cache
    queryClient.setQueryData<TItem[]>(queryKey, (old) => {
      return old ? old.filter((i) => i.id !== itemId) : []
    })

    let hasUndone = false

    const timeoutId = setTimeout(() => {
      pendingTimeoutsRef.current.delete(itemId)
      if (hasUndone) return

      deleteMutation.mutate(itemId, {
        onError: (error) => {
          // Roll back cache on error
          queryClient.setQueryData(queryKey, previousItems)
          const err = error as AxiosError<{
            message?: string
            errors?: string[]
          }>
          const msg =
            err.response?.data.errors?.[0] ??
            err.response?.data.message ??
            messages.fallbackError ??
            messages.errorTitle
          toast.add({
            title: messages.errorTitle,
            description: msg,
            type: 'error',
          })
        },
      })
    }, delayMs)

    pendingTimeoutsRef.current.set(itemId, timeoutId)

    // Display toast with Undo action
    const toastId = toast.add({
      title: messages.deleted,
      type: 'success',
      actionProps: {
        children: messages.undo,
        onClick: () => {
          hasUndone = true
          clearTimeout(timeoutId)
          pendingTimeoutsRef.current.delete(itemId)
          toast.close(toastId)

          // Restore cache
          queryClient.setQueryData(queryKey, previousItems)
          toast.add({
            title: messages.restored,
            type: 'success',
          })
        },
      },
    })
  }

  return {
    deleteWithUndo,
    isDeleting: deleteMutation.isPending,
  }
}
