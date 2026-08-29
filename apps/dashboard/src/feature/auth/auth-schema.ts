import { z } from 'zod'
import type { TFunction } from 'i18next'

export const createLoginSchema = (t: TFunction) =>
  z.object({
    email: z.string().trim().email(t('form.emailInvalid')),
    password: z
      .string()
      .min(8, t('form.passwordMin'))
      .regex(/[A-Z]/, { message: t('form.passwordUppercase') }),
  })

export type LoginFormValues = z.infer<ReturnType<typeof createLoginSchema>>
