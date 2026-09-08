export interface ApiResponse<T> {
  data: T
  message?: string
  success: boolean
  error?: string
  errors?: string[]
  statusCode?: number
}
