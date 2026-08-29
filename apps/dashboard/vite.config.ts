import { defineConfig } from 'vite'
import { devtools } from '@tanstack/devtools-vite'

import { tanstackRouter } from '@tanstack/router-plugin/vite'

import viteReact from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import Fonts from 'unplugin-fonts/vite'
import mkcert from 'vite-plugin-mkcert'

const config = defineConfig({
  resolve: { tsconfigPaths: true },
  plugins: [
    devtools(),
    tailwindcss(),
    tanstackRouter({ target: 'react', autoCodeSplitting: true }),
    viteReact(),
    Fonts({
      fontsource: {
        families: [
          {
            name: 'Inter Variable',
            styles: ['normal'],
            subset: 'latin',
            variable: true
          },
          {
            name: 'Tajawal',
            styles: ['normal'],
            subset: 'arabic',
            weights: [400, 500, 700, 900],
          },
        ],
      },
    }),
    mkcert()
  ],
})

export default config
