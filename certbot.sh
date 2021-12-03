kubectl create -f - << EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: development-selfsigned-issuer
  namespace: default
spec:
  selfSigned: {}
EOF
kubectl delete secret nats-tls-cert --wait || echo "Secret not deleted"
kubectl create -f - << EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nats-tls-cert
  namespace: default
spec:
  isCA: false
  secretName: nats-tls-cert
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - demo-org
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - "nats"
    - "nats.default"
    - "nats.default.svc"
    - "nats.default.svc.cluster"
    - "nats.default.svc.cluster.local"
  issuerRef:
    name: development-selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
EOF
