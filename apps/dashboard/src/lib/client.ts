import { useAuthStore } from '#/feature/auth/auth-store'
import axios from 'axios'

import type { AxiosError, InternalAxiosRequestConfig } from 'axios'

const API_URL = import.meta.env.VITE_API_URL

export const apiClient = axios.create({
  baseURL: API_URL,
  withCredentials: true,
  headers: {
    'X-Client-Type': 'web',
  },
})

const refreshClient = axios.create({
  baseURL: API_URL,
  withCredentials: true,
  headers: {
    'X-Client-Type': 'web',
  },
})

let csrfToken: string | null = null
let refreshPromise: Promise<string> | null = null
let authInitPromise: Promise<void> | null = null

interface RetryableRequestConfig extends InternalAxiosRequestConfig {
  _retry?: boolean
}

export async function getCsrfToken(): Promise<string> {
  if (csrfToken) {
    return csrfToken
  }

  const response = await refreshClient.get('/Auth/csrf-token')

  const token = response.data.data.csrfToken

  if (!token) throw new Error('csrf token not sent from the server')

  return token
}

async function refreshAccessToken(): Promise<string> {
  if (refreshPromise) {
    return refreshPromise
  }

  refreshPromise = (async () => {
    try {
      const token = await getCsrfToken()

      const response = await refreshClient.post(
        '/Auth/refresh',
        {},
        {
          headers: {
            'X-XSRF-TOKEN': token,
          },
        },
      )

      const newAccessToken = response.data.data.accessToken

      useAuthStore.getState().setAccessToken(newAccessToken)

      return newAccessToken
    } catch (error) {
      csrfToken = null
      useAuthStore.getState().clearAuth()

      throw error
    } finally {
      refreshPromise = null
    }
  })()

  return refreshPromise
}

/**
 * Restores a session on app startup using the HttpOnly refresh cookie.
 * Single-flight: concurrent callers share the same pending promise.
 * Resolves regardless of success/failure so route guards can proceed.
 */
export function ensureAuthInitialized(): Promise<void> {
  if (useAuthStore.getState().isAuthenticated) {
    return Promise.resolve()
  }

  if (authInitPromise) {
    return authInitPromise
  }

  authInitPromise = (async () => {
    useAuthStore.getState().setInitializing(true)

    try {
      await refreshAccessToken()
    } catch {
      // refreshAccessToken already clears the auth store on failure.
    } finally {
      useAuthStore.getState().setInitializing(false)
      authInitPromise = null
    }
  })()

  return authInitPromise
}

apiClient.interceptors.request.use(
  async (config) => {
    const accessToken = useAuthStore.getState().accessToken

    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`
    }

    // State-changing requests must carry the double-submit CSRF token (web flow).
    const method = config.method?.toUpperCase()
    if (method && ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
      try {
        const token = await getCsrfToken()
        config.headers['X-XSRF-TOKEN'] = token
      } catch {
        // no CSRF token available; the request will fail server-side if required
      }
    }

    return config
  },
  (error) => Promise.reject(error),
)

apiClient.interceptors.response.use(
  (response) => response,

  async (error: AxiosError) => {
    const originalRequest = error.config as RetryableRequestConfig | undefined

    if (
      error.response?.status !== 401 ||
      !originalRequest ||
      originalRequest._retry
    ) {
      return Promise.reject(error)
    }

    originalRequest._retry = true

    try {
      const newAccessToken = await refreshAccessToken()

      originalRequest.headers.Authorization = `Bearer ${newAccessToken}`

      return apiClient(originalRequest)
    } catch {
      window.location.href = '/login'

      return Promise.reject(error)
    }
  },
)
