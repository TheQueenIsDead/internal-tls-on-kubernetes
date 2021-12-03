package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"github.com/nats-io/nats.go"
	"io/fs"
	"io/ioutil"
	"log"
	"strings"
	"time"
)

const (
	rootCACertDir = "/certs"
)

// https://forfuncsake.github.io/post/2017/08/trust-extra-ca-cert-in-go-app/

func loadCerts() tls.Config {

	fmt.Printf("Loading certs from %s\n", rootCACertDir)

	// Find all files in the root CA Cert dir
	files, err := ioutil.ReadDir(rootCACertDir)
	if err != nil {
		log.Fatal(err)
	}

	// Filter for only *.crt files
	filtered := []fs.FileInfo{}
	for _, file := range files {
		if strings.HasSuffix(file.Name(), ".crt") {
			filtered = append(filtered, file)
		}
	}

	fmt.Println("Enumerating provided CA certs")
	rootCAs := &x509.CertPool{}
	for _, f := range filtered {
		fmt.Println("Processing: ", f.Name())

		// Get the SystemCertPool, continue with an empty pool on error
		rootCAs, _ = x509.SystemCertPool()
		if rootCAs == nil {
			rootCAs = x509.NewCertPool()
		}

		// Read in the cert file
		certs, err := ioutil.ReadFile(fmt.Sprintf("%s/%s", rootCACertDir, f.Name()))
		if err != nil {
			log.Fatalf("Failed to append %q to RootCAs: %v\n", f.Name(), err)
		}

		// Append our cert to the system pool
		if ok := rootCAs.AppendCertsFromPEM(certs); !ok {
			log.Println("No certs appended, using system certs only")
		}
	}

	config := tls.Config{
		RootCAs: rootCAs,
	}

	return config

	//// You can also supply a complete tls.Config
	//
	//certFile := "./configs/certs/client-cert.pem"
	//keyFile := "./configs/certs/client-key.pem"
	//cert, err := tls.LoadX509KeyPair(certFile, keyFile)
	//if err != nil {
	//	t.Fatalf("error parsing X509 certificate/key pair: %v", err)
	//}
	//
	//config := &tls.Config{
	//	ServerName: 	opts.Host,
	//	Certificates: 	[]tls.Certificate{cert},
	//	RootCAs:    	pool,
	//	MinVersion: 	tls.VersionTLS12,
	//}
	//
	//nc, err = nats.Connect("nats://localhost:4443", nats.Secure(config))
	//if err != nil {
	//	t.Fatalf("Got an error on Connect with Secure Options: %+v\n", err)
	//}
}

func publish(config *tls.Config) {

	fmt.Println("Publishing")

	//config := &tls.Config{
	//	ServerName: 	opts.Host,
	//	Certificates: 	[]tls.Certificate{cert},
	//	RootCAs:    	pool,
	//	MinVersion: 	tls.VersionTLS12,
	//}

	nc, err := nats.Connect("tls://nats:4222", nats.Secure(config))
	if err != nil {
		log.Fatalf("Error establishing connection to NATS: %+v\n", err)
	} else {
		fmt.Println("Connected to NATS via TLS!")
	}

	// Simple Publisher
	for {
		fmt.Println("Sending message...")
		err = nc.Publish("foo", []byte("Hello World"))
		if err != nil {
			fmt.Println(err)
		}
		time.Sleep(5 * time.Second)
	}
}

func main() {

	fmt.Println("Hello world!")

	tlsConf := loadCerts()
	publish(&tlsConf)

}
