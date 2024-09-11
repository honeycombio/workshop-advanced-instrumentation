package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

var years = []int{2015, 2016, 2017, 2018, 2019, 2020}

func main() {
	cleanup := initTracer()
	defer cleanup()

	handleYear := func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)

		// do something asynchronously
		go doSomeWork()

		year := getYear(r.Context())

		span := trace.SpanFromContext(r.Context())
		span.SetAttributes(
			attribute.String("foo", "bar"),
			attribute.Int("year", year),
		)
		_, _ = fmt.Fprintf(w, "%d", year)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		_, _ = fmt.Fprintf(w, "service: <a href='/year'>/year</a>")
	})

	// Wrap the handler with otelhttp for auto-instrumentation
	otelHandler := otelhttp.NewHandler(http.HandlerFunc(handleYear), "/year")

	// Use the otelHandler
	http.Handle("/year", otelHandler)

	log.Println("Listening on ", ":6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
}

func doSomeWork() {
	tracer := otel.Tracer("")
	_, span := tracer.Start(context.Background(), "some-work")
	span.SetAttributes(attribute.String("otel", "rocks"))
	time.Sleep(time.Duration(500) * time.Millisecond)
	defer span.End()
}

func getYear(ctx context.Context) int {
	rnd := rand.Intn(len(years))
	year := years[rnd]
	tracer := otel.Tracer("")
	_, span := tracer.Start(ctx, "getYear")
	span.SetAttributes(
		attribute.Int("random-index", rnd),
		attribute.Int("year", year),
	)
	defer span.End()
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	return year
}

func initTracer() func() {

	ctx := context.Background()

	exporter, err := otlptracegrpc.New(ctx)
	if err != nil {
		log.Fatal(err)
	}
	provider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
	)
	otel.SetTracerProvider(provider)

	return func() {
		ctx := context.Background()
		err := provider.Shutdown(ctx)
		if err != nil {
			log.Fatal(err)
		}
	}
}
