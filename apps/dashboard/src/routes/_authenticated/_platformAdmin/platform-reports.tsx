import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/platform-reports')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.platformReports.title')}
        description={t('pages.platformReports.description')}
      />
      <div className="grid grid-cols-2 gap-4">
        <div className="rounded-lg border bg-card p-6">
          <div className="text-sm text-muted-foreground">Total Tenants</div>
          <div className="mt-2 text-3xl font-bold">1,284</div>
          <div className="text-xs text-muted-foreground">+12% this month (dummy)</div>
        </div>
        <div className="rounded-lg border bg-card p-6">
          <div className="text-sm text-muted-foreground">MRR</div>
          <div className="mt-2 text-3xl font-bold">$42,300</div>
          <div className="text-xs text-muted-foreground">Platform revenue dummy</div>
        </div>
      </div>
    </>
  )
}
