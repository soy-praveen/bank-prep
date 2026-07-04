import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// base './' keeps asset URLs relative so the build works at any GitHub Pages path
export default defineConfig({
  base: './',
  plugins: [react(), tailwindcss()],
})
