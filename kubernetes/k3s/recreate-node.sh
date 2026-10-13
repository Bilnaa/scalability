#!/bin/sh
# Recrée le nœud k3s (conteneur Apple `container`), installe ArgoCD et redéploie l'appli (chart Helm)
# Usage : sh kubernetes/k3s/recreate-node.sh [cpus] [memory]   (défaut : 2 CPU / 4G)
# Attention : le cluster est remis à zéro (aucun volume persistant -> données Postgres perdues)
set -e

CPUS=${1:-2}
MEMORY=${2:-4G}
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
export KUBECONFIG=~/.kube/k3s-apple.yaml

# 1. Recréation du conteneur k3s
container stop k3s-node 2>/dev/null || true
container rm k3s-node 2>/dev/null || true
container run -d --name k3s-node --cpus "$CPUS" --memory "$MEMORY" --cap-add ALL \
  --tmpfs /run --tmpfs /var/run -p 127.0.0.1:6443:6443 \
  --entrypoint /bin/sh docker.io/rancher/k3s:v1.33.5-k3s1 \
  -c 'mount -o remount,rw /proc/sys && mount -o remount,rw /sys/fs/cgroup 2>/dev/null; exec /bin/k3s server --disable=traefik --tls-san 127.0.0.1'

# 2. Récupération du kubeconfig (nouveaux certificats à chaque création)
until container exec k3s-node test -f /etc/rancher/k3s/k3s.yaml 2>/dev/null; do sleep 2; done
container exec k3s-node cat /etc/rancher/k3s/k3s.yaml | sed 's/: default$/: k3s-apple/' > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
until kubectl get node 2>/dev/null | grep -q ' Ready'; do sleep 2; done

# 3. Ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/cloud/deploy.yaml
kubectl annotate ingressclass nginx ingressclass.kubernetes.io/is-default-class=true --overwrite
kubectl -n ingress-nginx wait --for=condition=complete job --all --timeout=180s
kubectl -n ingress-nginx rollout status deploy/ingress-nginx-controller --timeout=180s

# 4. ArgoCD + Application -> déploie le chart helm/kube-starter depuis notre fork
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=180s
kubectl apply -f "$ROOT/kubernetes/argocd/argo-cd-k3s.yaml"
until kubectl get deploy api-deployment >/dev/null 2>&1; do sleep 5; done
kubectl rollout status deploy/postgres-deployment deploy/api-deployment deploy/webapp-deployment --timeout=300s

echo
echo "IP du nœud : $(container list | awk '/k3s-node/ {print $6}' | cut -d/ -f1)  (à mettre dans /etc/hosts pour myapp.local)"
