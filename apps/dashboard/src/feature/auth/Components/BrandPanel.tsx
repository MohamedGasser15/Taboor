import { useTranslation } from 'react-i18next'
import { Logo } from '#/components/brand/logo'
import NowServingBoard from './NowServingBoard'

export default function BrandPanel() {
  const { t } = useTranslation('auth')

  return (
    <aside className="relative hidden overflow-hidden bg-linear-to-br from-deep-teal via-ink to-ink p-8 lg:flex lg:flex-col lg:justify-between xl:p-12">
      <div
        className="pointer-events-none absolute -top-40 -right-40 size-[34rem] rounded-full bg-teal/20 blur-3xl"
        aria-hidden="true"
      />
      <div
        className="pointer-events-none absolute -bottom-52 -left-32 size-[30rem] rounded-full bg-amber/10 blur-3xl"
        aria-hidden="true"
      />

      <div className="relative">
        <Logo tone="light" size="md" scale={1.5} />
      </div>

      <div className="relative mt-12 space-y-5">
        <h2 className="max-w-md text-3xl leading-tight font-black tracking-tight text-paper xl:text-4xl">
          {t('brand.tagline')}
        </h2>
        <p className="max-w-sm text-sm leading-relaxed text-white/70 xl:text-base">
          {t('brand.taglineDescription')}
        </p>
      </div>

      <div className="relative mt-10">
        <NowServingBoard />
      </div>

      <p className="relative mt-8 text-xs text-white/50">{t('brand.footer')}</p>
    </aside>
  )
}
