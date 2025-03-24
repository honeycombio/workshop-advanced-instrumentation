// Example filename: tracing.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
// import { ConsoleSpanExporter } from '@opentelemetry/sdk-trace-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';
import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-http';
import { logs, SeverityNumber } from '@opentelemetry/api-logs';
import {
  LoggerProvider,
  SimpleLogRecordProcessor
} from '@opentelemetry/sdk-logs';

const resource = new Resource({
  [ATTR_SERVICE_NAME]: 'frontend',
});

const sdk: NodeSDK = new NodeSDK({
  traceExporter: new OTLPTraceExporter(),
  // traceExporter: new ConsoleSpanExporter(),
  resource: resource,
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

const logExporter = new OTLPLogExporter();
const loggerProvider = new LoggerProvider({
  resource: resource
});
loggerProvider.addLogRecordProcessor(new SimpleLogRecordProcessor(logExporter));
logs.setGlobalLoggerProvider(loggerProvider);

const customLogger = {
  info: (message: string, attributes = {}) => {
    logs.getLogger("frontend.custom.logger").emit({
      body: message,
      severityNumber: SeverityNumber.INFO,
      attributes,
    });
  },
  error: (message: string, attributes = {}) => {
    logs.getLogger("frontend.custom.logger").emit({
      body: message,
      severityNumber: SeverityNumber.ERROR,
      attributes,
    });
  },
  debug: (message: string, attributes = {}) => {
    logs.getLogger("frontend.custom.logger").emit({
      body: message,
      severityNumber: SeverityNumber.DEBUG,
      attributes,
    });
  },
};

console.log("🟢 Starting SDK");
sdk.start();

export { customLogger as logger };