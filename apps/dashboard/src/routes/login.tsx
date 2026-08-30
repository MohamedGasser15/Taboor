import { createFileRoute, redirect } from '@tanstack/react-router'

import BrandPanel from '#/feature/auth/Components/BrandPanel'
import LoginForm from '#/feature/auth/Components/LoginForm'
import { useAuthStore } from '#/feature/auth/auth-store'
import { ensureAuthInitialized } from '#/lib/client'
import { isPlatformAdmin } from '#/lib/isPlatformAdmin'

export const Route = createFileRoute('/login')({
  beforeLoad: async () => {
    await ensureAuthInitialized()

    const { isAuthenticated, user } = useAuthStore.getState()

    if (isAuthenticated) {
      // Exact backend strings only: "Admin", "Customer", "User"
      // User is not allowed on dashboard web — stay on login (will be cleared below if somehow authenticated)
      if (user?.role === "User") {
        useAuthStore.getState().clearAuth()
        return
      }
      throw redirect({
        to: isPlatformAdmin(user) ? '/plans' : '/dashboard',
      })
    }
  },

  component: LoginPage,
})

function LoginPage() {
  return (
    <div className="flex h-dvh overflow-hidden">
      <BrandPanel />
      <LoginForm />
    </div>
  )
}
