This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:6003](http://localhost:6003) with your browser to see the result.

The frontend will also start [node-year](../06-propagation/node-year) and [node-name](../06-propagation/node-name) concurrently, and calls the `/name` and `/year` service when the page loads.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

### Setting up the OpenTelemetry

- add `components/observability.tsx` to your project
  ```javascript
    // observability.jsx|tsx
    "use client"; // browser only: https://react.dev/reference/react/use-client
    import { HoneycombWebSDK } from '@honeycombio/opentelemetry-web';
    import { getWebAutoInstrumentations } from '@opentelemetry/auto-instrumentations-web';

    declare global {
        var __OTEL_INITIALIZED__: boolean;
    }
    
    const configDefaults = {
    ignoreNetworkEvents: true,
    // propagateTraceHeaderCorsUrls: [
    // /.+/g, // Regex to match your backend URLs. Update to the domains you wish to include.
    // ]
    }
    export default function Observability(){
    if (!global.__OTEL_INITIALIZED__) {
        global.__OTEL_INITIALIZED__ = true;
        try {
            const sdk = new HoneycombWebSDK({
            // endpoint: "https://api.eu1.honeycomb.io/v1/traces", // Send to EU instance of Honeycomb. Defaults to sending to US instance.
            debug: true, // Set to false for production environment.
            apiKey: '<YOUR_API_KEY_HERE>', // Replace with your Honeycomb Ingest API Key.
            serviceName: 'web', // Replace with your application name. Honeycomb uses this string to find your dataset when we receive your data. When no matching dataset exists, we create a new one with this name if your API Key has the appropriate permissions.
            instrumentations: [getWebAutoInstrumentations({
                // Loads custom configuration for xml-http-request instrumentation.
                '@opentelemetry/instrumentation-xml-http-request': configDefaults,
                '@opentelemetry/instrumentation-fetch': configDefaults,
                '@opentelemetry/instrumentation-document-load': configDefaults,
            })],
            });
            sdk.start();
        } catch (e) {return null;}
    }
    return null;
    }
  ```
  - make sure to set the Honeycomb API Key with the valid value.
- add `import Observability from './components/observability';` to your `app/layout.tsx` file
- add `<Observability />` to your `app/layout.tsx` file
- add `apiKey` and `serviceName` to the `Observability` component
- add the following instrumentation libraries of opentelemetry to `package.json` file
  ```json
    "@honeycombio/opentelemetry-web": "^0.13.0",
    "@opentelemetry/api": "^1.9.0",
    "@opentelemetry/api-logs": "^0.57.2",
    "@opentelemetry/auto-instrumentations-node": "^0.56.1",
    "@opentelemetry/auto-instrumentations-web": "^0.45.1",
    "@opentelemetry/instrumentation": "^0.57.2",
    "@opentelemetry/sdk-logs": "^0.57.2"
  ```
- add the `instrumentation.ts` file to the main directory which has the following code:
  ```javascript
    import { NodeSDK } from '@opentelemetry/sdk-node';
    import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
    import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

    const sdk: NodeSDK = new NodeSDK({
    traceExporter: new OTLPTraceExporter(),
    instrumentations: [    
        getNodeAutoInstrumentations({
        // We recommend disabling fs automatic instrumentation because 
        // it can be noisy and expensive during startup
        '@opentelemetry/instrumentation-fs': {
            enabled: false,
        },
        }),
    ],
    });

    sdk.start();
  ```
- add the `../instrumentation.ts` to the `tsconfig.json` file, in the `include` section
  ```json
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts", "../instrumentation.ts"],
  ```
- run `npm install`
- run `npm run build` to build the project (optional)
- run `npm run start`