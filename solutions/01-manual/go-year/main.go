package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gorilla/mux/otelmux"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.7.0"
	"go.opentelemetry.io/otel/trace"
	"google.golang.org/grpc/credentials"
)

var years = []int{2015, 2016, 2017, 2018, 2019, 2020}

func main() {
	// Call initTracer and return a function called cleanup
	// Defer calling that function
	// This pattern diverges from official documentation a bit where
	// Boilerplate code is part of your main function
	cleanup := initTracer()
	defer cleanup()

	r := mux.NewRouter()
	r.Use(otelmux.Middleware("go-year"))

	r.HandleFunc("/year", func(w http.ResponseWriter, r *http.Request) {
		rand.Seed(time.Now().UnixNano())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)

		year := getYear(r.Context())

		span := trace.SpanFromContext(r.Context())
		span.SetAttributes(
			attribute.String("foo", "bar"),
			attribute.Int("year", year),
		)

		fmt.Fprintf(w, "%d", year)
	})
	http.Handle("/", r)

	log.Println("Listening on ", ":6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
}

func getYear(ctx context.Context) int {
	rnd := rand.Intn(len(years))
	year := years[rnd]
	tracer := otel.Tracer("")               // Give your tracer a name if you like
	_, span := tracer.Start(ctx, "getYear") // _ just says we don't care about the context returned here
	span.SetAttributes(
		attribute.Int("random-index", rnd),
		attribute.Int("year", year),
	)
	defer span.End() // defer ending
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	return year
}

func initTracer() func() {

	// Top-level Context for incoming requests
	ctx := context.Background()

	// Create otlp grpc trace exporter to be able to retrieve
	// the collected spans.
	// HNY supports OTLP over grpc or HTTP protobuf
	exporter, err := otlptracegrpc.New(ctx)
	if err != nil {
		log.Fatal(err)
	}

	// Register the exporter with the TracerProvider using
	// a BatchSpanProcessor
	provider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
	)

	otel.SetTracerProvider(provider)

	return func() {
		ctx := context.Background()
		// Shutdown will flush any remaining spans and shut down the exporter
		err := provider.Shutdown(ctx)
		if err != nil {
			log.Fatal(err)
		}
	}
}

func initTracerTheHardWay() func() {
	apikey, _ := os.LookupEnv("HONEYCOMB_API_KEY")
	dataset, _ := os.LookupEnv("HONEYCOMB_DATASET")

	// Set GRPC options to establish an insecure connection to an OpenTelemetry Collector
	opts := []otlptracegrpc.Option{
		otlptracegrpc.WithTLSCredentials(credentials.NewClientTLSFromCert(nil, "")),
		otlptracegrpc.WithEndpoint("api.honeycomb.io:443"),
		otlptracegrpc.WithHeaders(map[string]string{
			"x-honeycomb-team":    apikey,
			"x-honeycomb-dataset": dataset,
		}),
	}

	// Create the exporter
	exporter, err := otlptrace.New(context.Background(), otlptracegrpc.NewClient(opts...))
	if err != nil {
		log.Fatalf("failed to create Otel exporter: %v", err)
	}

	provider := sdktrace.NewTracerProvider(
		sdktrace.WithSampler(sdktrace.AlwaysSample()),
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceNameKey.String("go-year"),
		)),
	)
	otel.SetTracerProvider(provider)

	// This callback will ensure all spans get flushed before the program exits.
	return func() {
		ctx := context.Background()
		err := provider.Shutdown(ctx)
		if err != nil {
			log.Fatal(err)
		}
	}
}
