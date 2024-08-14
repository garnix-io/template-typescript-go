package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/mux"
)

func handleRequest(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "huhu\n")
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/", handleRequest)
	http.Handle("/", r)
	fmt.Println("Backend listening on port 3000")
	http.ListenAndServe(":3000", nil)
}
