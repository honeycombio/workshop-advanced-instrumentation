# Asynchronous

We update our asynchronous calls and pass context to them. Doing so, enables the spans to be created in the parent context.

## Java

OpenTelemetry leverages Java thread context, which can be attached to our runnable via the context wrapper with
`Context.current().wrap(runnable)`.

## Go

Since trace context is stored in a Go `context.Context`. We need to pass this context, and leverage it when creating any 
new span. This may require changes to function and method signatures in order to accept a context object. The best practice
for this in Go, is to pass context as the first parameter.

## NodeJS

While Node will handle async calbacks fairly well, it will attach the asynchronous spans to the active context. It is good to know how to change the active span in conext for which the async spans may fall under with  [`tracer.startActiveSpan()`](https://open-telemetry.github.io/opentelemetry-js-api/interfaces/tracer.html#startactivespan). You can also manually change the active span with `context.with(trace.setSpan(context.active(), parent),  () => { });`