const process = require("process");
const { Metadata, credentials } = require("@grpc/grpc-js");

const { NodeSDK } = require("@opentelemetry/sdk-node");
const { getNodeAutoInstrumentations } = require("@opentelemetry/auto-instrumentations-node");
const { Resource } = require("@opentelemetry/resources");
const { ATTR_SERVICE_NAME } = require("@opentelemetry/semantic-conventions");
const { OTLPTraceExporter } =  require("@opentelemetry/exporter-trace-otlp-grpc")

const metadata = new Metadata()
metadata.set("x-honeycomb-team", process.env.HONEYCOMB_API_KEY);
metadata.set("x-honeycomb-dataset", process.env.HONEYCOMB_DATASET);
const traceExporter = new OTLPTraceExporter({
    url: "grpc://api.honeycomb.io:443/",
    credentials: credentials.createSsl(),
    metadata
});

const sdk = new NodeSDK({
    resource: new Resource({
        [ATTR_SERVICE_NAME]: "node-year",
    }),
    traceExporter,
    instrumentations: [getNodeAutoInstrumentations()]
});

sdk.start()
    .then(() => console.log("Tracing initialized"))
    .catch((error) => console.log("Error initializing tracing", error));

process.on("SIGTERM", () => {
    sdk.shutdown()
        .then(() => console.log("Tracing terminated"))
        .catch((error) => console.log("Error terminating tracing", error))
        .finally(() => process.exit(0));
});