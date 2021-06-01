# Span Links

Span Links allow us to connect casually related traces. Span can contain 0 or more links to spans located in the same or 
other traces.A popular use case is a batch process which creates multiple jobs, each with their own trace. The traces for 
each job can be linked back to the batch process using span links. Since span Links may be part of sampling decisions, 
they must be defined at span creation time.

## Java

You can add links to spans, using the `addLink()` method. An overloaded version that accepts attributes can also be 
used to add a span link.

## Go

When creating/starting a span in Go, the variadic function can receive an optional set of SpanOption arguments. Using  
`trace.WithLinks`, links can be added to the span at creation time. Links are created using a `SpanContext` and optional
attributes.
