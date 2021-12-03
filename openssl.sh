# https://kubernetes.io/docs/tasks/administer-cluster/certificates/
cat <<-EOF > ./certs/csr.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = AB
ST = CD
L = EFGHI
O = JKLMNOP
OU = QRSTUVWXYZ

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = nats
DNS.2 = nats.default
DNS.3 = nats.default.svc
DNS.4 = nats.default.svc.cluster
DNS.5 = nats.default.svc.cluster.local


[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF

# Generate a CA key
openssl genrsa -out ./certs/ca.key 2048
# Generate a CA crt based on the key
openssl req -x509 -new -nodes -key ./certs/ca.key -days 10000 -out ./certs/ca.crt -config ./certs/csr.conf
# Generate a server key (NATS)
openssl genrsa -out ./certs/server.key 2048
# Generate a CSR for the server based on the above config
openssl req -new -key ./certs/server.key -out ./certs/server.csr -config ./certs/csr.conf
# Generate the server cert using the sr and the CA key and certificate
openssl x509 -req \
  -in ./certs/server.csr \
  -CA ./certs/ca.crt \
  -CAkey ./certs/ca.key \
  -CAcreateserial \
  -out ./certs/server.crt \
  -days 10000 \
  -extensions v3_ext \
  -extfile ./certs/csr.conf

# View the CSR and signed certificate
openssl req  -noout -text -in ./certs/server.csr
openssl x509  -noout -text -in ./certs/server.crt