# Kubernetes info

#### Types d'apiVersion

apiVersion -> Resource examples

<span style="color: #FF10F0;">v1</span> -> Pod, Service, ConfigMap, Secret, Namespace

<span style="color: #FF10F0;">apps/v1</span> -> Deployment, StatefulSet, DaemonSet, ReplicaSet

<span style="color: #FF10F0;">batch/v1</span> -> Job, CronJob

<span style="color: #FF10F0;">networking.k8s.io/v1</span> -> Ingress, NetworkPolicy

<span style="color: #FF10F0;">autoscaling/v2</span> -> HorizontalPodAutoscaler

# Minikube

A éviter : `minikube start --nodes 10` -> très gourmande en recourses, l'ordi risque d'éxploser !

`minikube start --driver=docker`

`minikube status`

`minikube addons enable ingress`

`minikube delete`

# Kubectl

`kubectl get all`

`kubectl get node`

`kubectl get pods`

`kubectl describe pod <nom-du-pod`

`kubectl get pods -A`

`kubectl get services`

`kubectl get ingresss`

`kubectl get namespaces`

`kubectl get configmap`

`kubectl get secret`

`kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80`

`kubectl get pods -n ingress-nginx`

`kubectl get ingress`

`kubectl exec -it <pod name> -- /bin/bash`

`kubectl logs <pod-name>`

`kubectl get pods -n <namespace>`

`kubectl run broken-pod --image=nginx:does-not-exist` -> commande pour lancer un pod qui tombe en erreur

`kubectl delete pod broken-pod`

#### Lancement des applications

`kubectl apply -f postgres-secret.yaml`

`kubectl apply -f postgres-config.yaml`

`kubectl apply -f postgres.yaml`

`kubectl apply -f api.yaml`

`kubectl apply -f webapp.yaml`

`kubectl apply -f ingress.yaml`

## URL de l'appli

http://myapp.local:8080/dashboard

# k3s (Mac Apple Silicon, via `container`)

Les images Docker Hub sont amd64 uniquement -> on les rebuild en arm64 et on les importe dans k3s

`export KUBECONFIG=~/.kube/k3s-apple.yaml`

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/cloud/deploy.yaml`

`kubectl annotate ingressclass nginx ingressclass.kubernetes.io/is-default-class=true`

`docker build --platform linux/arm64 -t kube-starter-api:local applications/kube-starter-api`

`docker build --platform linux/arm64 -t kube-starter-webapp:local applications/kube-starter-webapp`

`docker save kube-starter-api:local | container exec -i k3s-node ctr -n k8s.io images import -`

`docker save kube-starter-webapp:local | container exec -i k3s-node ctr -n k8s.io images import -`

`kubectl apply -k kubernetes/k3s`

Ajouter `192.168.64.3 myapp.local` dans `/etc/hosts` -> http://myapp.local/dashboard

# Runner

### Installation

`New-Item -ItemType Directory -Force -Path C:\GitLab-Runner`

`Set-Location C:\GitLab-Runner`

`cd C:\GitLab-Runner`

`$url = "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe"`

`Invoke-WebRequest -Uri $url -OutFile .\gitlab-runner.exe`

`Get-Item .\gitlab-runner.exe | Select-Object Name, Length`

`.\gitlab-runner.exe --version`

### Registrer son runner

`.\gitlab-runner.exe register`

`.\gitlab-runner.exe list`

`.\gitlab-runner.exe verify`

`.\gitlab-runner.exe run`

# Mis en place Argo CD

`kubectl create namespace argocd`

`kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`

`kubectl port-forward svc/argocd-server -n argocd 9090:443`

`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"`

`[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")))` -> décodage MDP sur Windows

`kubectl apply -f <mon-composant-argo-cd>`

`kubectl get application argo-cd-app -n argocd`

`kubectl get application argo-cd-app -n argocd -o yaml`

`kubectl get applications -n argocd`

`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d` -> décodage MDP sur Mac/Linux

Sur k3s (Mac) : `kubectl apply -f kubernetes/argocd/argo-cd-k3s.yaml` -> suit notre fork + overlay `kubernetes/k3s`

#### URL ArgoCD

https://localhost:9090

# Liens

Repo applications TP : https://github.com/AngelRafaelGO/scalability/tree/master

Repo DockerHub :

- https://hub.docker.com/repository/docker/angelrafael/applications-kube-starter-api
- https://hub.docker.com/repository/docker/angelrafael/applications-kube-starter-webapp/general

Gitlab runner : https://docs.gitlab.com/runner/install/windows/

Doc GitLab CI : https://docs.gitlab.com/ci/

Télécharger Docker Desktop : https://www.docker.com/products/docker-desktop/

Docker cheat sheet : https://www.docker.com/resources/cli-cheat-sheet/

Installation Minikube : https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download

Documentation Kubernetes : https://kubernetes.io/docs/home/

Commandes kubectl : https://kubernetes.io/docs/reference/kubectl/quick-reference/

Argo CD : https://argo-cd.readthedocs.io/en/stable/

Documentation officielle Argo CD Githun : https://github.com/argoproj/argo-cd/blob/master/docs/getting_started.md

Helm Charts : https://helm.sh/docs/topics/charts/
