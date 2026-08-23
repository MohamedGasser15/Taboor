import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30 * 1000, // Globally treat data as fresh for 30s
      gcTime: 1000 * 60 * 10,    // Garbage collect unused cache after 10 minutes
      retry: 3,                 // Retry failing requests only once
      refetchOnWindowFocus: false, // Turn off aggressive background fetching
      refetchOnReconnect: true,
    }
  }
});