package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"go.opentelemetry.io/otel/propagation"

	"github.com/gorilla/mux"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gorilla/mux/otelmux"
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

	r := mux.NewRouter()
	r.Use(otelmux.Middleware("go-year"))

	r.HandleFunc("/year", func(w http.ResponseWriter, r *http.Request) {
		rand.Seed(time.Now().UnixNano())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)

		go doSomeWork(r.Context())

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

func doSomeWork(ctx context.Context) {
	tracer := otel.Tracer("")
	_, span := tracer.Start(ctx, "some-work")
	span.SetAttributes(attribute.String("otel", "rocks"))
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	span.AddEvent("my event", trace.WithAttributes(attribute.String("more", "details")))
	time.Sleep(time.Duration(rand.Intn(150)+100) * time.Millisecond)
	span.AddEvent("another event")

	go generateLinkedTrace(ctx)

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

func generateLinkedTrace(ctx context.Context) {
	tracer := otel.Tracer("")
	srcSpanCtx := trace.SpanContextFromContext(ctx)

	ctx, span := tracer.Start(context.Background(), "go-generated-span",
		trace.WithLinks(trace.Link{SpanContext: srcSpanCtx}),
		trace.WithAttributes(attribute.Int("depth", 1)),
	)
	defer span.End()

	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	addRecursiveSpan(ctx, 2, 5)
}

func addRecursiveSpan(ctx context.Context, depth int, maxDepth int) {
	tracer := otel.Tracer("")
	ctx, span := tracer.Start(ctx, "generated-span",
		trace.WithAttributes(attribute.Int("depth", depth)),
	)
	defer span.End()
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	if depth < maxDepth {
		addRecursiveSpan(ctx, depth+1, maxDepth)
	}
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
	// To propagate trace context over the wire, a propagator must be registered with the OpenTelemetry API
	// Here we register a unified TextMapPropagator from the TraceContext and baggage propagator globally
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))

	return func() {
		ctx := context.Background()
		err := provider.Shutdown(ctx)
		if err != nil {
			log.Fatal(err)
		}
	}
}
