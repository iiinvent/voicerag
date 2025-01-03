import path from "path";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    build: {
        outDir: "../backend/static",
        emptyOutDir: true,
        sourcemap: true,
        commonjsOptions: {
            include: [/node_modules/],
            transformMixedEsModules: true,
            requireReturnsDefault: 'auto'
        },
        rollupOptions: {
            external: [
                'html-parse-stringify',
                'void-elements',
                'scheduler',
                'motion-utils',
                'motion-dom',
                '@emotion/is-prop-valid',
                'framesync',
                'popmotion',
                'style-value-types',
                'cross-fetch'
            ],
            output: {
                manualChunks: {
                    vendor: ['react', 'react-dom', 'react-i18next', 'i18next'],
                    ui: ['@radix-ui/react-slot', '@radix-ui/react-compose-refs', 'framer-motion']
                }
            }
        }
    },
    resolve: {
        preserveSymlinks: true,
        alias: {
            "@": path.resolve(__dirname, "./src"),
            'html-parse-stringify': path.resolve(__dirname, 'node_modules/html-parse-stringify/dist/html-parse-stringify.module.js'),
            'void-elements': path.resolve(__dirname, 'node_modules/void-elements/index.js'),
            'framer-motion': path.resolve(__dirname, 'node_modules/framer-motion/dist/es/index.mjs'),
            'cross-fetch': path.resolve(__dirname, 'node_modules/cross-fetch/dist/browser-ponyfill.js')
        }
    },
    optimizeDeps: {
        include: [
            'react-i18next',
            'framer-motion',
            '@radix-ui/react-slot',
            '@radix-ui/react-compose-refs',
            'html-parse-stringify',
            'void-elements',
            'scheduler',
            'motion-utils',
            'motion-dom',
            '@emotion/is-prop-valid',
            'framesync',
            'popmotion',
            'style-value-types',
            'cross-fetch'
        ],
        esbuildOptions: {
            target: 'es2020'
        }
    },
    server: {
        proxy: {
            "/realtime": {
                target: "ws://localhost:8765",
                ws: true,
                rewriteWsOrigin: true
            }
        }
    }
});
