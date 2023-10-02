#operator-sdk olm install
#kubectl get pods -n olm
kubectl label --overwrite ns olm \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/audit=restricted
#kubectl create namespace argocd
kubectl create -n olm -f ./argocd/catalog_source.yaml
kubectl get catalogsources -n olm
kubectl get pods -n olm -l olm.catalogSource=argocd-catalog
kubectl create -n argocd -f ./argocd/operator_group.yaml
kubectl get operatorgroups -n argocd
kubectl create -n argocd -f ./argocd/subscription.yaml
kubectl get subscriptions -n argocd
kubectl get installplans -n argocd
kubectl get pods -n argocd
# Should be in the form 
#---
#apiVersion: v1
#kind: Secret
#metadata:
#  name: vault-configuration
#  namespace: argocd
#stringData:
#  AVP_TYPE: awssecretsmanager
#  AWS_REGION: us-west-2
#  AWS_ACCESS_KEY_ID:
#  AWS_SECRET_ACCESS_KEY: 
#type: Opaque
kubectl apply -f ./argocd/secret-vault-configuration.yaml
#apiVersion: v1
#kind: Secret
#metadata:
#  name: argocd-github
#  namespace: argocd
#  labels:
#    "app.kubernetes.io/part-of": "argocd"
#data:
#  clientSecret: 
#  username: 
#  password: 
#type: Opaque
kubectl apply -f ./argocd/argocd-github-secret.yaml
kubectl apply -f ./argocd/configmap-plugin.yaml
kubectl apply -f ./argocd/crd-argocd.yaml

helm repo add ngrok https://ngrok.github.io/kubernetes-ingress-controller
helm install ngrok-ingress-controller ngrok/kubernetes-ingress-controller \
  --namespace ngrok-ingress-controller \
  --create-namespace \
  --set credentials.apiKey=$NGROK_API_KEY \
  --set credentials.authtoken=$NGROK_AUTHTOKEN
kubectl get po -n  ngrok-ingress-controller

kubectl apply -f ./argocd/ingress.yaml