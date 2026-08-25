import { Logo } from '#/components/brand/logo'
import { Button } from '#/components/ui/button'
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from '#/components/ui/field'
import { Input } from '#/components/ui/input'
import { useNavigate } from '@tanstack/react-router'
import { Eye, EyeOff } from 'lucide-react'
import { useState } from 'react'
import { useLogin } from '../hooks/use-login'
import { Controller, useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { loginSchema } from '../auth-schema'
import type { LoginFormValues } from '../auth-schema'
import { Spinner } from '#/components/ui/spinner'

export default function LoginForm() {
  const navigate = useNavigate()
  const login = useLogin()
  const [showPassword, setShowPassword] = useState(false)

  const form = useForm({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      password: '',
    },
  })

  const onSubmit = (values: LoginFormValues) => {
    login.mutate(values, {
      onSuccess: () => {
        navigate({
          to: '/dashboard',
        })
      },
    })
  }

  return (
    <main className="flex flex-1 items-center justify-center bg-paper px-6 py-8 sm:px-12">
      <div className="w-full max-w-lg">
        <div className="mb-6 lg:hidden">
          <Logo size="sm" />
        </div>

        <span className="text-xs font-semibold tracking-widest text-teal uppercase">
          Business dashboard
        </span>
        <h1 className="mt-3 text-3xl font-black tracking-tight text-ink sm:text-4xl">
          Welcome back
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Sign in to manage your location&rsquo;s queue.
        </p>

        <form className="mt-7 space-y-4" onSubmit={form.handleSubmit(onSubmit)}>
          <FieldGroup>
            <Controller
              name="email"
              control={form.control}
              render={({ field, fieldState }) => (
                <Field data-invalid={fieldState.invalid}>
                  <FieldLabel htmlFor={field.name}>Email</FieldLabel>
                  <Input
                    {...field}
                    id={field.name}
                    // type="email"
                    autoComplete="email"
                    placeholder="you@business.com"
                    className="h-11 text-base"
                    aria-invalid={fieldState.invalid}
                  />
                  {fieldState.invalid && (
                    <FieldError errors={[fieldState.error]} />
                  )}
                </Field>
              )}
            />

            <Controller
              name="password"
              control={form.control}
              render={({ field, fieldState }) => (
                <Field data-invalid={fieldState.invalid}>
                  <FieldLabel htmlFor={field.name}>Password</FieldLabel>
                  <div className="relative">
                    <Input
                      {...field}
                      id={field.name}
                      type={showPassword ? 'text' : 'password'}
                      autoComplete="current-password"
                      placeholder="••••••••"
                      className="h-11 pr-11 text-base"
                      aria-invalid={fieldState.invalid}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((v) => !v)}
                      className="absolute top-1/2 right-3 -translate-y-1/2 rounded-md p-1 text-muted-foreground transition-colors hover:text-ink focus-visible:ring-3 focus-visible:ring-ring/50 focus-visible:outline-none"
                      aria-label={
                        showPassword ? 'Hide password' : 'Show password'
                      }
                    >
                      {showPassword ? (
                        <EyeOff className="size-4" />
                      ) : (
                        <Eye className="size-4" />
                      )}
                    </button>
                  </div>
                  {fieldState.invalid && (
                    <FieldError errors={[fieldState.error]} />
                  )}
                </Field>
              )}
            />
          </FieldGroup>

          <div className="flex items-center justify-between">
            <label className="flex cursor-pointer items-center gap-2 text-sm text-muted-foreground select-none">
              <input
                type="checkbox"
                name="remember"
                className="size-4 rounded border-input accent-teal"
              />
              Remember me
            </label>
            <a
              href="#"
              className="text-sm font-medium text-teal transition-colors hover:text-ink"
            >
              Forgot password?
            </a>
          </div>

          <Button
            type="submit"
            className="h-12 w-full text-base"
            disabled={login.isPending}
          >
            {login.isPending ? (
              <>
                Signing in
                <Spinner />
              </>
            ) : (
              'Sign in'
            )}
          </Button>

          {login.isError && (
            <p className="text-sm text-destructive" role="alert">
              Invalid email or password.
            </p>
          )}
        </form>
      </div>
    </main>
  )
}
