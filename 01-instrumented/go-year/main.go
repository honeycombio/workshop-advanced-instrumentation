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
		year := getYear(r.Context())

		span := trace.SpanFromContext(r.Context())
		span.SetAttributes(
			attribute.String("foo", "bar"),
		)

		response := map[string]interface{}{
			"language": "Go",
			"year":     year,
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

func getYear(ctx context.Context) int {
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
	return year
}
