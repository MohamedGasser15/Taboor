import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/queues/active')(
  {
    component: RouteComponent,
  },
)

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Active Queues"
        description="Queues currently open at your location."
      />
      <div className="text-sm text-muted-foreground">
        Active Queues — under construction
      </div>
    </>
  )
}
