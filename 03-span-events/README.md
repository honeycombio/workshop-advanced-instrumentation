# Span Events

Adding events to our spans can be used to understand point in time events in longer running operations, capture details
about errors, and more. Adding Span Events are part of the OpenTelemetry API and can be done to any span that hasn't ended.

## Java

The `span.addEvent(name)` can be used to add a simple event with just a name. The method is overloaded with 
`span.addEvent(name, attributes)` to add an event with 1 or more attributes.

## Go

The `span.AddEvent(name, options)` is a variadic function which can receive a set of optional EventOption parameters. 
You can use `trace.WithAttributes(...)` as an EventOption to set attributes on a span event.

## Node

The `span.addEvent(name)` can be used to add a simple event with just a name. The method is overloaded with 
`span.addEvent(name, attributes)` to add an event with 1 or more attributes.
