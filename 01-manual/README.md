# Manual Instrumentation

Manual instrumentation is adding attributes to existing spans, and creating new spans (or traces) to better understand 
our code.

## Java
Adding auto-instrumentation with Java is accomplished by attaching the OpenTelemetry Java Agent to the application.
The agent requires specific environment variables to be set which you can find in [run.sh](run.sh). Once set the Agent
will autoconfigure and being to emit traces about the service. Traces emitted can be extended with additional attributes
to existing spans and/or new spans. The agent supports numerous 
[configuration](https://github.com/open-telemetry/opentelemetry-java-instrumentation/blob/main/docs/agent-config.md) options 
controlled with environment variables.

We can use the `@WithSpan` annotation to wrap any function with a new span. Since Java maintains thread context we 
can leverage that to get the current span using `Span.current()`.

## Go
Auto-instrumentation for a Go service requires code to be added to the service's startup. Once added, spans will be
emitted for instrumented frameworks (ie: gorilla/mux). Traces emitted can be extending with additional attributes to
existing spans and/or new spans.

Go requires to explicitly pass context for manual instrumentation. Span context is stored in the general context as a value.
You can get access to the current span from that context with `trace.SpanFromContext(ctx)`.
