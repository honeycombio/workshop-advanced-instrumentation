# hnycon - Advanced Instrumentation Workshop

Exercises to help you learn advanced instrumentation techniques with OpenTelemetry and Honeycomb. 
To get the most value from these exercies you are expected to have a basic knowledge of distributed tracing.

## Prerequisites
The exercises in this repository are built using Java and Go.

For Java, a version 11 or greater JDK is required. 
The [Gradle](https://gradle.org/) build tool is used to build all Java exercises. You will need it installed on your 
system to run the Java services.

For Go, version 1.14 or greater is required.

## Getting Started

1. Clone this repository
```shell
git clone https://github.com/honeycombio/workshop-advanced-instrumentation.git workshop
cd workshop
```

2. Setup your local environment with your Honeycomb API Key and Dataset name. You will need a Honeycomb Team in order to
get your API key.  For Dataset name, we recommend `greeting` but you can make this whatever you like.
```shell
source setup-env.sh YOUR_API_KEY greeting -w
```

Each exercise is stored in its own folder, with some exercises (1, 2, 5) having an additional starting point.

### Running and stopping services
Within each exercise folder is a `run.sh` and `stop.sh` file. These are used to build and run as well as stop any of the 
services used in the exercise. The run script can also be used to start the service in the background for quick testing.

The syntax for the run script is:
```shell
run.sh <service-name> [-b]
```
Where the optional `-b` argument will start the service in the background. Valid service names will depend on the exercise and are 
limited to: `go-name`, `go-year`, `java-name`, and `java-year` 

The syntax for the stop script is:
```shell
stop.sh [service-name]
```
The `service-name` is optional and if not specific all services we be stopped.