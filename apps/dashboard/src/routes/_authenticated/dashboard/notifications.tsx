import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/notifications')(
  {
    component: RouteComponent,
  },
)

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Notifications"
        description="Alerts and updates for your location."
      />
      <div className="text-sm text-muted-foreground">
        Notifications — under construction
      </div>
    </>
  )
}
