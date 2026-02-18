# Honeycomb Advanced Instrumentation Workshop

Exercises to help you learn advanced instrumentation techniques with OpenTelemetry and Honeycomb.
To get the most value from these examples you are expected to have a basic knowledge of distributed tracing.

NOTE: if you're looking for the Advanced Instrumentation workshop at Honeycomb's Observability Day events, that is [here](https://github.com/honeycombio/observability-day-workshop).

## Workshop slides

This workshop is meant to be an instructor led workshop, but that shouldn't prevent anyone from doing the workshop themselves.
Follow along with the [slides](https://docs.google.com/presentation/d/1xZa8r6Lp5PVYh9G1E8h0-BoQcuO6VoUAL9SlRQJYuGQ/edit?usp=sharing).

Make sure to read the speaker notes to get full context on the slide content.

## Running and Stopping workshop services

Within each example folder is a `run.sh` and `stop.sh` file. These are used to build and run as well as stop any of the
services used in the examples. The run script can also be used to start the service in the background for quick testing.

The syntax for the run script is:

```shell
run.sh <service-name> [-b]
```

Where the optional `-b` argument will start the service in the background.
Valid service names will depend on the example and are limited to: `go-name`, `go-year`, `java-name`, `java-year`, `node-name`, `node-year`, `python-name`, `python-year`, `dotnet-name`, and `dotnet-year`.

The syntax for the stop script is:

```shell
stop.sh [service-name]
```

`service-name` is optional and if not specific all services we be stopped.

## Using GitHub Codespace (recommended)

1. You can conveniently use GitHub's codespace to run the workshop on its devcontainter.

- Visit https://github.com/honeycombio/workshop-advanced-instrumentation
- Click `Code` button.
- Click `Create codespace ...` button to create the new workspace.

<center><img src="images/codespace-01.png" width="50%"/></center>

In case there are existing workspace, you can reuse existing one, or click `+` button to create a new workspace.

2. Set up your local environment with your Honeycomb API Key. You will need a Honeycomb Team in order to
   get your API key. If you don't have a Honeycomb Team you can sign up for a free one [here](https://honeycomb.io/signup).

```shell
source setup-env.sh YOUR_API_KEY
```

## Using Local System

You can also run the workshop on your local system.
You will need to ensure you have the proper prerequisites installed, and do some additional setup to your local environment.

### Prerequisites

The following toolchains are required to run the workshop:
- Java 21+
   - Gradle 8+
- Go 1.24+
- Node 22+
- Python 3.9+
- .NET 8+

### Java agent (for Java services)

Java examples (e.g. `run.sh java-year`, `run.sh java-name`) and the `16-message-queue` example run with the [OpenTelemetry Java agent](https://opentelemetry.io/docs/zero-code/java/agent/). The agent JAR is not included in the repo. Either:

1. **Download via script (recommended):** From the repo root, run:
   ```shell
   ./scripts/download-java-agent.sh
   ```
   This places `opentelemetry-javaagent.jar` in the `lib/` directory (which is gitignored).

2. **Manual download:** Download the latest [opentelemetry-javaagent](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases) JAR from the GitHub releases, and save it as `lib/opentelemetry-javaagent.jar`.

### Setup local environment

1. Clone this repository

```shell
git clone https://github.com/honeycombio/workshop-advanced-instrumentation.git workshop
cd workshop
```

2. Set up your local environment with your Honeycomb API Key. You will need a Honeycomb Team in order to
   get your API key. If you don't have a Honeycomb Team you can sign up for a free one [here](https://honeycomb.io/signup).
   The `-w` option will write the environment variables to your shell profile.

```shell
source setup-env.sh YOUR_API_KEY
```

Each example is stored in its own numbered folder, and builds from the prior example. Some examples (1, 2, 5) have an additional
starting point because something new was added which is outside the scope of this workshop (ie: adding multi-thread logic).
