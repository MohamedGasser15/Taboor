import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/platform-settings')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.platformSettings.title')}
        description={t('pages.platformSettings.description')}
      />
      <div className="rounded-lg border bg-card p-6">
        <h3 className="font-semibold">Platform Settings (Dummy)</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Global knobs: maintenance mode, feature flags, allowed origins. Clearly platform-only — contrast with
          <code> /dashboard/settings</code> (tenant system group).
        </p>
        <div className="mt-4 flex gap-2">
          <div className="rounded-md border px-3 py-2 text-sm">Maintenance: OFF (dummy toggle)</div>
          <div className="rounded-md border px-3 py-2 text-sm">Signup: OPEN</div>
        </div>
      </div>
    </>
  )
}
