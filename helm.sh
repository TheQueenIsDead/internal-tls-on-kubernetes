helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
helm repo list
helm upgrade --install nats nats/nats -f values.yaml

# Install CRD - Installing the CRD separately ensures that Certificates are not lost when the chart is installed
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml
# Helm Repo
helm repo add jetstack https://charts.jetstack.io
helm repo update
# Install
helm upgrade --install cert-manager jetstack/cert-manager --version v1.6.1