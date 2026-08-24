import { createFileRoute, redirect } from '@tanstack/react-router'

import BrandPanel from '#/feature/auth/Components/BrandPanel'
import LoginForm from '#/feature/auth/Components/LoginForm'
import { useAuthStore } from '#/feature/auth/auth-store'
import { ensureAuthInitialized } from '#/lib/client'

export const Route = createFileRoute('/login')({
  beforeLoad: async () => {
    await ensureAuthInitialized()

    const { isAuthenticated } = useAuthStore.getState()

    if (isAuthenticated) {
      throw redirect({
        to: '/dashboard',
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
