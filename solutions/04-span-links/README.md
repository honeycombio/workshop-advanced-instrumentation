# Span Links

Span Links allow us to connect casually related traces. A span can contain 0 or more links to other spans located in the 
same or different traces. A popular use case is a batch process which creates multiple jobs, each with their own trace. 
The traces for each job can be linked to the batch process using span links. Since span Links may be part of sampling 
decisions, they must be defined at span creation time.

## Java

You can add a link to a span, using the `addLink(spanContext)` method part of the `SpanBuilder`. An overloaded version 
that accepts attributes can also be used to add a span link.

## Go

When creating/starting a span in Go, the variadic function can receive an optional set of `SpanOption` arguments. Using  
`trace.WithLinks(trace.Link{SpanContext: spanContext})`, links can be added to the span at creation time. Links are created using a `SpanContext` and optional
attributes.

## Node

When creating/starting a span in Node, the startSpan function can receive an optional set of `SpanOptions` arguments. Using  
`tracer.startSpan(name: string, options?: SpanOptions, context?: Context): Span`, [links](https://open-telemetry.github.io/opentelemetry-js-api/interfaces/tracer.html#startspan) can be added to the span at creation time. Links are created using a `SpanContext` and optional
attributes. 

