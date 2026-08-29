import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute(
  '/_authenticated/dashboard/queues/scheduled',
)({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Scheduled Queues"
        description="Queues booked in advance."
      />
      <div className="text-sm text-muted-foreground">
        Scheduled Queues — under construction
      </div>
    </>
  )
}
