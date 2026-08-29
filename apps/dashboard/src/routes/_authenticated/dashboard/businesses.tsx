import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/businesses')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader
        title="Businesses"
        description="Locations and businesses on the platform."
      />
      <div className="text-sm text-muted-foreground">
        Businesses — under construction
      </div>
    </>
  )
}
