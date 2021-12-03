helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
helm repo list
helm upgrade --install nats nats/nats -f values.yaml
