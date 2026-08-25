import { useAuthStore } from '../auth-store'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { authApi } from '../api/auth-api'

export function useLogout() {
  const clearAuth = useAuthStore((state) => state.clearAuth)
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: authApi.logout,

    onSettled: () => {
      clearAuth()
      queryClient.clear()

      // Full page navigation: guarantees a fresh module + cookie state so the
      // session-restore on the login page sees the cleared cookie and cannot
      // resurrect the session (a plain SPA navigate can bounce back).
      window.location.assign('/login')
    },
  })
}
