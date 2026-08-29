import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute(
  '/_authenticated/dashboard/queues/now-serving',
)({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Now Serving"
        description="Who is currently being served."
      />
      <div className="text-sm text-muted-foreground">
        Now Serving — under construction
      </div>
    </>
  )
}
