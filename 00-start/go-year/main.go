package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"
)

var years = []int{2015, 2016, 2017, 2018, 2019, 2020}

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		_, _ = fmt.Fprintf(w, "service: <a href='/year'>/year</a>")
	})

	http.HandleFunc("/year", func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
		response := map[string]interface{}{
			"language":  "Go",
			"year":      getYear(),
			"generated": time.Now(),
		}
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, fmt.Sprintf("Error encoding JSON: %v", err), http.StatusInternalServerError)
		}
	})

	log.Println("Listening on ", ":6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
}

func getYear() int {
	rnd := rand.Intn(len(years))
	year := years[rnd]
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	return year
}
