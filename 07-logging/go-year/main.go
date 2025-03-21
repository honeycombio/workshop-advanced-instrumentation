package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

var years = []int{2015, 2016, 2017, 2018, 2019, 2020}

var logger = newLogger("go-year")

func main() {
	// Call setupOTelSDK and return a function called cleanup
	// Defer calling the cleanup function
	// We are throwing away errors here, but you can handle them if you like
	cleanup, _ := setupOTelSDK(context.Background())
	defer func() {
		_ = cleanup(context.Background())
	}()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		_, _ = fmt.Fprintf(w, "service: <a href='/year'>/year</a>")
	})

	handleYear := func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)

		// do something asynchronously
		go doSomeWork(r.Context())

		year := getYear(r.Context())

		span := trace.SpanFromContext(r.Context())
		span.SetAttributes(
			attribute.String("foo", "bar"),
		)

		response := map[string]interface{}{
			"language":  "Go",
			"year":      year,
			"generated": time.Now(),
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, fmt.Sprintf("Error encoding JSON: %v", err), http.StatusInternalServerError)
		}
	}
	// Wrap the handler with otelhttp for auto-instrumentation
	otelHandler := otelhttp.NewHandler(http.HandlerFunc(handleYear), "/year")

	// Use the otelHandler
	http.Handle("/year", otelHandler)

	log.Println("Listening on ", ":6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
}

// pass in context instead of blank context
func doSomeWork(ctx context.Context) {
	tracer := otel.Tracer("")
	_, span := tracer.Start(ctx, "some-work")
	defer span.End()
	span.SetAttributes(attribute.String("otel", "rocks"))
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	// add span event
	span.AddEvent("my event", trace.WithAttributes(attribute.String("more", "details")))
	time.Sleep(time.Duration(rand.Intn(150)+100) * time.Millisecond)
	span.AddEvent("another event")

	go generateLinkedTrace(ctx)
}

func getYear(ctx context.Context) int {
	logger.InfoContext(ctx, "Getting year...")
	rnd := rand.Intn(len(years))
	year := years[rnd]
	tracer := otel.Tracer("")               // Give your tracer a name if you like
	_, span := tracer.Start(ctx, "getYear") // _ just says we don't care about the context returned here
	defer span.End()                        // defer ending
	span.SetAttributes(
		attribute.Int("random-index", rnd),
		attribute.Int("year", year),
	)
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	logger.DebugContext(ctx, "Got year", "year", year)
	return year
}

func generateLinkedTrace(ctx context.Context) {
	tracer := otel.Tracer("")
	srcSpanCtx := trace.SpanContextFromContext(ctx)

	ctx, span := tracer.Start(context.Background(), "generated-span-root",
		trace.WithLinks(trace.Link{SpanContext: srcSpanCtx}),
		trace.WithAttributes(attribute.Int("depth", 1)),
	)
	defer span.End()
	logger.DebugContext(ctx, "Generated span root")
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	addRecursiveSpan(ctx, 2, 5)
}

func addRecursiveSpan(ctx context.Context, depth int, maxDepth int) {
	tracer := otel.Tracer("")
	ctx, span := tracer.Start(ctx, "generated-span",
		trace.WithAttributes(attribute.Int("depth", depth)),
	)
	defer span.End()
	logger.DebugContext(ctx, "Generated span", "depth", depth)
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	if depth < maxDepth {
		addRecursiveSpan(ctx, depth+1, maxDepth)
	}
}
