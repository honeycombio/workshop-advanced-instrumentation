package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

var years = []int{2015, 2016, 2017, 2018, 2019, 2020}

func main() {

	r := mux.NewRouter()

	r.HandleFunc("/year", func(w http.ResponseWriter, r *http.Request) {
		rand.Seed(time.Now().UnixNano())
		time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
		year := getYear(r.Context())
		fmt.Fprintf(w, "%d", year)
	})
	http.Handle("/", r)

	log.Println("Listening on ", ":6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
}

func getYear(ctx context.Context) int {
	rnd := rand.Intn(len(years))
	year := years[rnd]
	time.Sleep(time.Duration(rand.Intn(250)) * time.Millisecond)
	return year
}
