// Example filename: tracing.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
// import { ConsoleSpanExporter } from '@opentelemetry/sdk-trace-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';

const sdk: NodeSDK = new NodeSDK({
  traceExporter: new OTLPTraceExporter(),
  // traceExporter: new ConsoleSpanExporter(),
  resource: new Resource({
    [ATTR_SERVICE_NAME]: 'frontend',
  }),
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

console.log("🟢 Starting SDK");
sdk.start();