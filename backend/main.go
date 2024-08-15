package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func handleRequest(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "hello from go\n")
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		panic(fmt.Sprintf("environment variable not set: PORT"))
	}
	r := mux.NewRouter()
	r.HandleFunc("/", handleRequest)
	http.Handle("/", r)
	fmt.Println("Backend listening on port " + port)
	http.ListenAndServe(":"+port, nil)
}
