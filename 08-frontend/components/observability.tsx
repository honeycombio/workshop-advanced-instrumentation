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
