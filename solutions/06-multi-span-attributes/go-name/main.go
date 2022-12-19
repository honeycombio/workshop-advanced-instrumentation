package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	beeline "github.com/honeycombio/beeline-go"
	"github.com/honeycombio/beeline-go/propagation"
	"github.com/honeycombio/beeline-go/wrappers/config"
	"github.com/honeycombio/beeline-go/wrappers/hnynethttp"
)

var namesByYear = map[int][]string{
	2015: []string{"sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah"},
	2016: []string{"sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah"},
	2017: []string{"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas"},
	2018: []string{"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden"},
	2019: []string{"sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson"},
	2020: []string{"olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas"},
}

func main() {
	beeline.Init(beeline.Config{
		WriteKey:    os.Getenv("HONEYCOMB_API_KEY"),
		Dataset:     os.Getenv("HONEYCOMB_DATASET"),
		ServiceName: "go-name",
	})
	defer beeline.Close()

	mux := http.NewServeMux()
	mux.HandleFunc("/name", func(w http.ResponseWriter, r *http.Request) {
		rand.Seed(time.Now().UnixNano())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
		year, _ := getYear(r.Context())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
		names := namesByYear[year]
		fmt.Fprintf(w, names[rand.Intn(len(names))])
	})

	log.Println("Listening on ", ":6002")
	log.Fatal(http.ListenAndServe(":6002", hnynethttp.WrapHandler(mux)))
}

func getYear(ctx context.Context) (int, context.Context) {
	ctx, span := beeline.StartSpan(ctx, "call /year")
	defer span.Send()
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	req, _ := http.NewRequestWithContext(ctx, "GET", "http://localhost:6001/year", nil)
	client := &http.Client{
		Transport: hnynethttp.WrapRoundTripperWithConfig(http.DefaultTransport, config.HTTPOutgoingConfig{HTTPPropagationHook: propagateTraceHook}),
		Timeout:   time.Second * 5,
	}
	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	body, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
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
	ctx, headers := propagation.MarshalW3CTraceContext(ctx, prop)
	return headers
}
