package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

var namesByYear = map[int][]string{
	2015: {"sophia", "jackson", "emma", "aiden", "olivia", "liam", "ava", "lucas", "mia", "noah"},
	2016: {"sophia", "jackson", "emma", "aiden", "olivia", "lucas", "ava", "liam", "mia", "noah"},
	2017: {"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "lucas"},
	2018: {"sophia", "jackson", "olivia", "liam", "emma", "noah", "ava", "aiden", "isabella", "caden"},
	2019: {"sophia", "liam", "olivia", "jackson", "emma", "noah", "ava", "aiden", "aria", "grayson"},
	2020: {"olivia", "noah", "emma", "liam", "ava", "elijah", "isabella", "oliver", "sophia", "lucas"},
}

type YearResponse struct {
	Generated string `json:"generated"`
	Language  string `json:"language"`
	Year      int    `json:"year"`
}

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
		_, _ = fmt.Fprintf(w, "service: <a href='/name'>/name</a>")
	})

	handleName := func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)

		year, err := getYear(r.Context())
		if err != nil {
			http.Error(w, fmt.Sprintf("Error getting year: %v", err), http.StatusInternalServerError)
			return
		}
		name := getName(year)

		response := map[string]interface{}{
			"language":  "Go",
			"year":      year,
			"name":      name,
			"generated": time.Now(),
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, fmt.Sprintf("Error encoding JSON: %v", err), http.StatusInternalServerError)
		}
	}
	// Wrap the handler with otelhttp for auto-instrumentation
	otelHandler := otelhttp.NewHandler(http.HandlerFunc(handleName), "/name")

	// Use the otelHandler
	http.Handle("/name", otelHandler)

	log.Println("Listening on ", ":6002")
	log.Fatal(http.ListenAndServe(":6002", nil))
}

func getYear(ctx context.Context) (int, error) {
	client := &http.Client{Transport: otelhttp.NewTransport(http.DefaultTransport)}
	req, err := http.NewRequestWithContext(ctx, "GET", "http://localhost:6001/year", nil)
	if err != nil {
		return 0, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return 0, err
	}

	var data YearResponse
	if err := json.Unmarshal(body, &data); err != nil {
		return 0, err
	}

	return data.Year, nil
}

func getName(year int) string {
	names := namesByYear[year]
	rnd := rand.Intn(len(names))
	return names[rnd]
}
