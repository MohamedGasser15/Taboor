import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import PageHeader from '#/components/layout/PageHeader'

export const Route = createFileRoute('/_authenticated/dashboard/support')({
  component: RouteComponent,
})

function RouteComponent() {
  const { t } = useTranslation('common')
  const title = t('pages.support.title')

  return (
    <>
      <PageHeader title={title} description={t('pages.support.description')} />
      <div className="text-sm text-muted-foreground">
        {t('underConstruction', { page: title })}
      </div>
    </>
  )
}
