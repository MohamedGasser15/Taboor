import { createFileRoute } from '@tanstack/react-router'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/support')({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <>
      <PageHeader title="Support" description="Help and contact resources." />
      <div className="text-sm text-muted-foreground">
        Support — under construction
      </div>
    </>
  )
}
