# Multi-span Attributes

Multi-span Attributes allow you to specify attributes that are automatically applied to all descendant spans, even
across services. Passing multi-span attributes across services, is accomplished with trace propagation using headers. 
Since each attribute requires additional network bandwidth, multi-span attributes should be used with care.

Honeycomb's Beestro SDKs, which are wrappers for OpenTelemetry, enable multi-span attributes using `Baggage` to propagate
the attributes, and a `SpanProcessor` which converts baggage items to attributes on export. The Honeycomb Beestro SDKs
are 100% compatible with all OpenTelemetry APIs.

The `name` service for Java has been added, to demonstrate the multi-span attributes functionality. This service will call
the `year` service from either Java or Go. A URL parameter for the service, was added to drive the multi-span attribute. 
You can control this value by passing a value to the `guess` URL parameter when calling the service.
```http request
http://localhost:6002/name?guess=sophia
```

# Java

The Honeycomb Beestro Agent, can be used in place of the OpenTelemetry Agent. Using this agent, enables Baggage items
to be exported. In order to add a new attribute to the existing and all descendent spans the following code can be used: 
```java
public static void addMultiSpanAttribute(String key, String value) {
    Span.current().setAttribute(key, value);
    Baggage.current()
            .toBuilder()
            .put(key, value)
            .build()
            .makeCurrent();
}
```

The [run.sh](run.sh) script supplied with this example has been updated to use the Honeycomb Beestro agent. The Honeycomb
specific environment variables used to control the agent, are also provided in the script.

