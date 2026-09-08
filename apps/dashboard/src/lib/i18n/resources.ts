import commonEn from '../../locales/en/common.json'
import authEn from '../../locales/en/auth.json'
import navbarEn from '../../locales/en/navbar.json'
import plansEn from '../../locales/en/plans.json'
import commonAr from '../../locales/ar/common.json'
import authAr from '../../locales/ar/auth.json'
import navbarAr from '../../locales/ar/navbar.json'
import plansAr from '../../locales/ar/plans.json'

const resources = {
  en: { common: commonEn, auth: authEn, navbar: navbarEn, plans: plansEn },
  ar: { common: commonAr, auth: authAr, navbar: navbarAr, plans: plansAr },
} as const

export default resources
