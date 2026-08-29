import commonEn from '../../locales/en/common.json'
import authEn from '../../locales/en/auth.json'
import navbarEn from '../../locales/en/navbar.json'
import commonAr from '../../locales/ar/common.json'
import authAr from '../../locales/ar/auth.json'
import navbarAr from '../../locales/ar/navbar.json'

const resources = {
  en: { common: commonEn, auth: authEn, navbar: navbarEn },
  ar: { common: commonAr, auth: authAr, navbar: navbarAr },
} as const

export default resources
