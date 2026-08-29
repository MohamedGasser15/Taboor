import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute(
  '/_authenticated/dashboard/queues/completed',
)({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Completed Queues"
        description="Recently finished queue sessions."
      />
      <div className="text-sm text-muted-foreground">
        Completed Queues — under construction
      </div>
    </>
  )
}
