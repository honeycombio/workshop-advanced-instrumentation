package main

import (
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
		year := getYear()
		_, _ = fmt.Fprintf(w, "%d", year)
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
