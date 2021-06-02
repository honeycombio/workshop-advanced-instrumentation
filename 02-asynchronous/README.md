# Asynchronous

We update our asynchronous calls and pass context to them. Doing so, enables the spans to be created in the parent context.

## Java

OpenTelemetry leverages Java thread context, which can be attached to our runnable via the context wrapper with
`Context.current().wrap(runnable)`.

## Go

Since trace context is stored in a Go `context.Context`. We need to pass this context, and leverage it when creating any 
new span. This may require changes to function and method signatures in order to accept a context object. The best practice
for this in Go, is to pass context as the first parameter.
