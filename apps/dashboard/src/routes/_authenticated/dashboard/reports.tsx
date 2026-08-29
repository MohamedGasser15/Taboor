import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/reports')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Reports"
        description="Analytics and insights for your location."
      />
      <div className="text-sm text-muted-foreground">
        Reports — under construction
      </div>
    </>
  )
}
