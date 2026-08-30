import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/_platformAdmin/audit-logs')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  return (
    <>
      <PageHeader
        title={t('pages.auditLogs.title')}
        description={t('pages.auditLogs.description')}
      />
      <div className="rounded-lg border bg-card p-6">
        <h3 className="font-semibold">Admin Audit Logs (Dummy)</h3>
        <p className="mt-2 text-sm text-muted-foreground">Every plan/tenant mutation logged via admin_audit_logs. Dummy timeline.</p>
        <div className="mt-4 space-y-3">
          {[
            '2026-08-30 — PlatformAdmin changed Plan Pro max_branches 3 → 5',
            '2026-08-29 — PlatformAdmin suspended tenant acme-corp',
            '2026-08-28 — PlatformAdmin created plan Enterprise',
          ].map((line) => (
            <div key={line} className="rounded-md bg-muted p-3 text-xs font-mono">
              {line}
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
