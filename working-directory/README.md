# Manual Instrumentation - "Starting point"

This is the starting point for all the examples. It consists of a service that will return a random year between 
2015 and 2020. The service is duplicated in Java and Go for this workshop.

When launched either service will listen on port `6001` for the `/year` endpoint.

## Java
The Java service is built on the popular [Spring Boot](https://spring.io/projects/spring-boot) framework, and all logic 
is within the YearController class.

## Go
The Go service is built using the [gorilla/mux](https://github.com/gorilla/mux) package for request routing.

## Node
The Node service is built using the [ExpressJS](https://github.com/expressjs/express) package for request routing.