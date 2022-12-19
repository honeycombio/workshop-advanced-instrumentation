# Asynchronous - "Starting Point"

This marks the starting point to instrument and understand asynchronous operations in a service. Here services have a new
asynchronous operation added. That operation is also instrumented, but the spans show up as a separate trace.

## Java

A new `Runnable` is started. The runnable calls our function which manually creates a span using the global trace provider. 
We could also use the `@WithSpan` annotation, but to avoid any ambiguity, the global trace provider was explicitly
used to create the span. Java maintains thread context, but since this span belongs to a new thread, it gets created as 
part of a new trace.

## Go

A function is called in a go routine. A new span is created within this function using `context.Background()`. Since the 
background context is unaware of our trace context, the span belongs to a separate trace.

## NodeJS

An async function is called. A new span is created within this function using async / await methods and will attach to the current context.  Node's single threaded, event loop nature will automatically handle the asynchonous nature of the node event loop.