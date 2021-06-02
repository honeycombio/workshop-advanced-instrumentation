# Propagation

Trace propagation allows traces to continue across services, even when different tracing SDKs are used.

In order to propagate traces from Honeycomb Beelines, you need to add tha appropriate tracing propagator to the Beeline's
init, or as part of the outbound call. For the Honeycomb Go Beeline, this is added as part of the outbound call as a 
`propagationHook` function which will look like this to propagate W3C headers: 
```go
func propagateTraceHook(r *http.Request, prop *propagation.PropagationContext) map[string]string {
	ctx := r.Context()
	ctx, headers := propagation.MarshalW3CTraceContext(ctx, prop)
	return headers
}
```

OpenTelemetry specification recommends that trace propagation and parsing is specified at the integration level, and not 
the SDK, though different languages implement this nuance differently.

## Java

When using the Java Agent, trace propagation for W3C headers is automatically enabled for all integrations. Nothing 
additional is required.

## Go

As of 0.20.0, the Go Gorilla/mux integration does not specify a propagator. One can be specified with the 
TraceProvider which will be leveraged by all SDKs. The W3C propagator, is specified as a `TextMapPropagator` like this: 
```go
otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))
```
