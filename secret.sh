kubectl create secret tls nats-tls \
  --cert=./certs/server.crt \
  --key=./certs/server.key

kubectl create secret generic demo-ca-crt \
  --from-file=ca.crt=./certs/ca.crt