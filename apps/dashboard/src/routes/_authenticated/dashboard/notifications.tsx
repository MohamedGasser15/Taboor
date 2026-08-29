import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/notifications')(
  {
    component: RouteComponent,
  },
)

function RouteComponent() {
  const { t } = useTranslation('common')
  const title = t('pages.notifications.title')

  return (
    <>
      <PageHeader
        title={title}
        description={t('pages.notifications.description')}
      />
      <div className="text-sm text-muted-foreground">
        {t('underConstruction', { page: title })}
      </div>
    </>
  )
}
