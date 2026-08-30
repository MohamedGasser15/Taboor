import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/tenants')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.tenants.title')}
        description={t('pages.tenants.description')}
      />
      <div className="rounded-lg border bg-card p-6">
        <h3 className="font-semibold">Tenants (Dummy)</h3>
        <p className="mt-2 text-sm text-muted-foreground">
          Platform-only list of all tenants. Tenant users never see this. Guarded by <code>isPlatformAdmin</code> in
          <code> _platformAdmin/route.tsx</code>.
        </p>
        <div className="mt-4 space-y-2">
          {['Acme Corp — Pro', 'Taboor Demo — Free', 'Contoso — Enterprise'].map((row) => (
            <div key={row} className="flex items-center justify-between rounded-md border p-3 text-sm">
              <span>{row}</span>
              <span className="text-xs text-muted-foreground">dummy</span>
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
