import { useAuthStore } from '../auth-store'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'
import { authApi } from '../api/auth-api'

export function useLogout() {
  const clearAuth = useAuthStore((state) => state.clearAuth)
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: authApi.logout,

    onSettled: () => {
      clearAuth()
      queryClient.clear()
      navigate({ to: '/login' })
    },
  })
}
