# Propagation - "Starting Point"

To demonstrate propagation, a new service is added to the stack. This new service, called `name`, contains a list of 
names by year. When called it will make a request to the `year` service to get a year, and return a random name from the
list of names for the given year.

This new service is written only in Go, but can depend on the year service from either Java or Go.

In order to show propagation across different formats, the new service is instrumented using the Honeycomb Beeline for Go
SDK. The Honeycomb Beeline SDKs support the ability to propagate headers in W3C format, which can be understood by 
OpenTelemetry SDKs.
