import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Dashboard"
        // description="Overview of your location's queue."
      />
      <div className="text-sm text-muted-foreground">
        Dashboard — under construction
      </div>
    </>
  )
}
