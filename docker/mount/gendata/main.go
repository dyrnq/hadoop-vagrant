package main

import (
	"io"
	"log"
	"net/http"
	"fmt"
	"github.com/brianvoe/gofakeit/v6"
	"time"
	"bytes"
)

func main2() {
	// Hello world, the web server

	helloHandler := func(w http.ResponseWriter, req *http.Request) {
		io.WriteString(w, "Hello, world!\n")
	}

	http.HandleFunc("/hello", helloHandler)
	log.Println("Listing for requests at http://localhost:8000/hello")
	log.Fatal(http.ListenAndServe(":8000", nil))
}


func main() {
	gofakeit.Seed(0)
	for true {

		
		for i := 0; i < 10000; i++ {
			domain:= gofakeit.DomainName()
			var buffer bytes.Buffer
			buffer.WriteString(gofakeit.IPv4Address())
			buffer.WriteString(",")
			buffer.WriteString(domain)
			buffer.WriteString(",")
			buffer.WriteString("20220730132613")
			buffer.WriteString(",")
			buffer.WriteString(gofakeit.IPv4Address())
			buffer.WriteString(",")
			buffer.WriteString("0")
			buffer.WriteString(",")
			buffer.WriteString("1")
			buffer.WriteString(",")
			buffer.WriteString(domain)
			buffer.WriteString(",")
			buffer.WriteString("\"\"")
			buffer.WriteString(",")
			buffer.WriteString(gofakeit.IPv4Address())
			fmt.Println(buffer.String())

		}
		time.Sleep(time.Second)

	}






}

