operator-sdk olm install
kubectl get pods -n olm
kubectl label --overwrite ns olm \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/audit=restricted
#Now creae argocd
kubectl create namespace argocd
kustomize build ./argocd | argocd-vault-plugin generate - | kubectl apply -f -
kustomize build ./argocd-image-updater | argocd-vault-plugin generate - | kubectl apply -f -
kubectl get catalogsources -n olm
kubectl get pods -n olm -l olm.catalogSource=argocd-catalog
kubectl get operatorgroups -n argocd
kubectl get subscriptions -n argocd
kubectl get installplans -n argocd
kubectl get pods -n argocd

helm repo add ngrok https://ngrok.github.io/kubernetes-ingress-controller
helm install ngrok-ingress-controller ngrok/kubernetes-ingress-controller \
  --namespace ngrok-ingress-controller \
  --create-namespace \
  --set credentials.apiKey=$NGROK_API_KEY \
  --set credentials.authtoken=$NGROK_AUTHTOKEN
kubectl get po -n  ngrok-ingress-controller

kustomize build ./knative-operator | argocd-vault-plugin generate - | kubectl apply -f -
cd istio-*
export PATH=$PWD/bin:$PATH
istioctl install -y 
