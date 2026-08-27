import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute(
  '/_authenticated/dashboard/queues/completed',
)({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div className="rounded-lg border bg-card p-6 text-sm text-muted-foreground">
      Completed Queues — under construction
    </div>
  )
}
