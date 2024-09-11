package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	// To get Beelines and OpenTelemetry instrumentation to interoperate, you will need to use W3C headers
	beeline "github.com/honeycombio/beeline-go"
	"github.com/honeycombio/beeline-go/propagation"
	"github.com/honeycombio/beeline-go/wrappers/config"
	"github.com/honeycombio/beeline-go/wrappers/hnynethttp"
)

var namesByYear = map[int][]string{
	2015: {"sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah"},
	2016: {"sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah"},
	2017: {"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas"},
	2018: {"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden"},
	2019: {"sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson"},
	2020: {"olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas"},
}

func main() {
	beeline.Init(beeline.Config{
		WriteKey:    os.Getenv("HONEYCOMB_API_KEY"),
		Dataset:     os.Getenv("HONEYCOMB_DATASET"),
		ServiceName: "go-name",
	})
	defer beeline.Close()

	mux := http.NewServeMux()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		_, _ = fmt.Fprintf(w, "service: <a href='/name'>/name</a>")
	})

	mux.HandleFunc("/name", func(w http.ResponseWriter, r *http.Request) {
		rand.Seed(time.Now().UnixNano())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
		year, _ := getYear(r.Context())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
		names := namesByYear[year]
		_, _ = fmt.Fprintf(w, names[rand.Intn(len(names))])
	})

	log.Println("Listening on ", ":6002")
	log.Fatal(http.ListenAndServe(":6002", hnynethttp.WrapHandler(mux)))
}

func getYear(ctx context.Context) (int, context.Context) {
	ctx, span := beeline.StartSpan(ctx, "call /year")
	defer span.Send()
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	req, _ := http.NewRequestWithContext(ctx, "GET", "http://localhost:6001/year", nil)
	// Specify an HTTPPropagationHook for outgoing W3C headers using the WrapRoundTripperWithConfig
	// HTTPPropagationHook returns a serialized header in W3C trace context format
	client := &http.Client{
		Transport: hnynethttp.WrapRoundTripperWithConfig(http.DefaultTransport, config.HTTPOutgoingConfig{HTTPPropagationHook: propagateTraceHook}),
		Timeout:   time.Second * 5,
	}
	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	body, err := io.ReadAll(res.Body)
	_ = res.Body.Close()
	if err != nil {
		panic(err)
	}
	year, err := strconv.Atoi(string(body))
	if err != nil {
		panic(err)
	}
	return year, ctx
}

func propagateTraceHook(r *http.Request, prop *propagation.PropagationContext) map[string]string {
	ctx := r.Context()
	// beeline includes marshal (and unmarshal) functions to generate and parse W3C trace context headers
	// beelines can automatically detect incoming W3C headers
	ctx, headers := propagation.MarshalW3CTraceContext(ctx, prop)
	return headers
}
