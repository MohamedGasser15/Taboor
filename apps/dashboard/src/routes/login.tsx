import { createFileRoute } from '@tanstack/react-router'

import BrandPanel from '#/feature/auth/Components/BrandPanel'
import LoginForm from '#/feature/auth/Components/LoginForm'

export const Route = createFileRoute('/login')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="flex h-dvh overflow-hidden">
      <BrandPanel />
      <LoginForm />
    </div>
  )
}
