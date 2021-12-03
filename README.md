# TLS on Kubernetes

## Background

TLS. Certificates. Certificate expiry.

What a time!

For public web traffic, we are fortunate that we have a plethora of trusted Root CA's, some paid,
and some offering free and automated encryption in order to make the world a better place 
(Thank you [LetsEncrypt](https://letsencrypt.org)).

It has become quite easy to install [cert-bot](https://certbot.eff.org/) on a server,
or utilise a cloud offering like AWS Route 53 and a cloud load balancer to automagically ensure
that certificates are valid, renewed, rotated, and initially deployed with little to no effort.

Publicly.

These work wonders for externally accessible domains, especially solutions using [ACME](https://letsencrypt.org/docs/challenge-types/)
but what happens when we want to operate behind the scenes, still utilising the same security standards
to mitigate snooping in the event of an intruder, or use mTLS to leverage a Zero Trust security framework?

Gets really fun, really quickly.

Anyone can create a cert and flop it around, but the art of the matter comes from enabling a solution
that requires as little manual overhead as possible, in a manner akin to a public cert-bot or cloud provider.

## Demo

In this demo, I'm going to show two things.
 - TLS authentication for a message queue on a local Kubernetes domain (`cluster.local)
 - And an interesting way to manage propagating certs to clients.

This demo is going to use NATS as the message queue, a python app as the client, and minikube behind the 
scenes to get it all working. Links to the above technologies can be found here, alongside other requirements:

### Requirements

| Requirement               | Link                                       |
|---------------------------|--------------------------------------------|
| Kubernetes (minikube)     | https://minikube.sigs.k8s.io/docs/start/  |
| Kubectl                   | https://kubernetes.io/docs/tasks/tools/   |
| Helm                      | https://helm.sh/                          |
| Docker                    | https://www.docker.com/                   |
| OpenSSL                   | https://www.openssl.org/                  |
| Python 3.10 (Optional)    | https://www.python.org/                  |


### Setup

Inspecta nd run the contents of the below scripts

```bash
# Start a minikube server 
./minikube.sh
# Generate a new self signed cert for nats
./openssl.sh
# Put it into a Kubernetes secret
./secret.sh
# Install nats into the server
./helm.sh
# Build and deploy our app
./deploy.sh
```

#### Nats Hostnames

We can see fromt he default installation, we need to accomodate for the following nats FQDNS's

```bash
david@DESKTOP-0NQCVD8:/mnt/z/go/src/github.com/internal-tls-on-kubernetes$ kubectl exec -n default -it deployment/nats-box -- /bin/sh -l
             _             _
 _ __   __ _| |_ ___      | |__   _____  __
| '_ \ / _` | __/ __|_____| '_ \ / _ \ \/ /
| | | | (_| | |_\__ \_____| |_) | (_) >  <
|_| |_|\__,_|\__|___/     |_.__/ \___/_/\_\

nats-box v0.7.0
nats-box-7b5dbfbb58-wgdfd:~# nslookup nats
Server:         10.96.0.10
Address:        10.96.0.10:53

** server can't find nats.cluster.local: NXDOMAIN

** server can't find nats.cluster.local: NXDOMAIN

** server can't find nats.svc.cluster.local: NXDOMAIN

** server can't find nats.svc.cluster.local: NXDOMAIN

*** Can't find nats.default.svc.cluster.local: No answer

Name:   nats.default.svc.cluster.local
Address: 172.17.0.6


```















# Other means

You could of course run your own CA, and there are a few decent options out there

 - Boulder https://github.com/letsencrypt/boulder


Traefik does alot of auto provisioning for you, which is rather delightful:

https://doc.traefik.io/traefik/https/acme/#configuration-examples

Mkcert allows for very easy local certificate creation, if developing:

https://github.com/FiloSottile/mkcert

You can change the default Kubernetes DNS domain from `cluster.local`,
but that could lead to interesting results mixing internal end external:

https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/

Consider this interesting DNS challenge idea for non cluster.local domains:

https://www.reddit.com/r/selfhosted/comments/q9jf2n/lets_encrypt_certificates_for_my_local_services/

Step CA can be installed and ran for all sorts of means, it is very versatile:

https://smallstep.com/docs/step-ca