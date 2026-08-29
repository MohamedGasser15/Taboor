import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/settings')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Settings"
        description="Preferences for your account and location."
      />
      <div className="text-sm text-muted-foreground">
        Settings — under construction
      </div>
    </>
  )
}
