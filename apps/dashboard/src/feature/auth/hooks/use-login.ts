import { useAuthStore } from "../auth-store";
import { useMutation } from "@tanstack/react-query";
import type { LoginRequest } from "../auth-types";
import { authApi } from "../api/auth-api";

export function useLogin() {
  const setAuth = useAuthStore((state) => state.setAuth);

  return useMutation({
    mutationFn: (credentials: LoginRequest) => 
      authApi.login(credentials),
    
    onSuccess: (data) => {
      setAuth(data.user, data.token)
    },
  })
}