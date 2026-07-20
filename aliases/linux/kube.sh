#!/bin/bash

# Strubloid::linux::kubernetes

## kubectl main commands
alias k="kubectl"

## generic kubectl subcommands
alias kg="kubectl get"
alias kd="kubectl describe"
alias kl="kubectl logs"
alias kex="kubectl exec -it"
alias kdel="kubectl delete"
alias ka="kubectl apply"
alias kaf="kubectl apply -f"
alias kak="kubectl apply -k"
alias kdry="kubectl apply -f --dry-run=client -o yaml"
alias ke="kubectl edit"
alias kpf="kubectl port-forward"
alias kcp="kubectl cp"
alias krr="kubectl rollout restart"
alias krs="kubectl rollout status"
alias kru="kubectl rollout undo"

## context and namespace
alias kctx="kubectl config use-context"
alias kctxl="kubectl config get-contexts"
alias kctxc="kubectl config current-context"
alias kns="kubectl config set-context --current --namespace"
alias knsc="kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}'"
alias kgns="kubectl get namespaces"

## resource listing shortcuts (get + resource)
alias kgp="kubectl get pods"
alias kgpa="kubectl get pods -A"
alias kgpw="kgp -o wide"
alias kgpy="kgp -o yaml"
alias kgpj="kgp -o json"
alias kgs="kubectl get svc"
alias kgsw="kgs -o wide"
alias kgn="kubectl get nodes"
alias kgnw="kgn -o wide"
alias kgd="kubectl get deployments"
alias kgda="kubectl get deployments -A"
alias kga="kubectl get all"
alias kgaa="kubectl get all -A"
alias kgi="kubectl get ingress"
alias kgcm="kubectl get configmap"
alias kgsec="kubectl get secret"
alias kgpvc="kubectl get pvc"
alias kgsa="kubectl get sa"
alias kgrb="kubectl get rolebindings"
alias kgcrb="kubectl get clusterrolebindings"
alias kgcr="kubectl get clusterroles"
alias kgev="kubectl get events --sort-by=.lastTimestamp"

## describe shortcuts
alias kdp="kubectl describe pod"
alias kds="kubectl describe svc"
alias kdd="kubectl describe deployment"
alias kdn="kubectl describe node"
alias kdcm="kubectl describe configmap"
alias kdsec="kubectl describe secret"

## delete shortcuts
alias kdelp="kubectl delete pod"
alias kdels="kubectl delete svc"
alias kdeld="kubectl delete deployment"
alias kdelns="kubectl delete namespace"

## logs related
alias klg="kubectl logs -f"
alias klgp="kubectl logs -f --previous"
alias klt="kubectl logs --tail=50"
alias klgt="klg --tail=0"

## top (resource usage)
alias ktopn="kubectl top nodes"
alias ktopp="kubectl top pods"
alias ktoppa="kubectl top pods -A"

## cleanup (cls pattern)
alias clskp="kubectl delete pod --all -n \$(knsc)"
alias clskall="kubectl delete all,cm,secret,ing,pvc,sa --all -n \$(knsc)"
alias clskns="kubectl delete namespace"
alias clskev="kubectl delete events --all -n \$(knsc)"

# fix ownership of kube config similar to dk-update
alias k-update="sudo chown -R \$USER:\$USER ~/.kube/"

# rolling restart a deployment with the current directory name
alias k-restart-current="kubectl rollout restart deployment -n \$(knsc) \$(basename \$(pwd))"

## entering a pod (interactive picker if no argument)
function k-enter(){

  local pod_name="$1"
  local pod_list selected_pod

  if [ -z "$pod_name" ]; then
    pod_list=$(kubectl get pods --no-headers -o custom-columns=NAME:.metadata.name)
    if [ -z "$pod_list" ]; then
      echo "No pods found in namespace \$(knsc)."
      return 1
    fi
    echo "Available pods:"
    select selected_pod in $pod_list; do
      if [ -n "$selected_pod" ]; then
        pod_name="$selected_pod"
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
  fi

  kubectl exec -it "$pod_name" -- /bin/bash
}

## entering a pod with sh fallback (useful for distroless/alpine)
function k-enter-sh(){

  local pod_name="$1"
  local pod_list selected_pod

  if [ -z "$pod_name" ]; then
    pod_list=$(kubectl get pods --no-headers -o custom-columns=NAME:.metadata.name)
    if [ -z "$pod_list" ]; then
      echo "No pods found in namespace \$(knsc)."
      return 1
    fi
    echo "Available pods:"
    select selected_pod in $pod_list; do
      if [ -n "$selected_pod" ]; then
        pod_name="$selected_pod"
        break
      else
        echo "Invalid selection. Try again."
      fi
    done
  fi

  kubectl exec -it "$pod_name" -- sh
}

## cluster status overview (mirrors docker-status)
function k-status(){
  echo "=== Nodes ==="
  kubectl get nodes -o wide
  echo ""
  echo "=== Namespaces ==="
  kubectl get namespaces
  echo ""
  echo "=== Pods (all namespaces) ==="
  kubectl get pods -A
  echo ""
  echo "=== Services (all namespaces) ==="
  kubectl get svc -A
  echo ""
  echo "=== Deployments (all namespaces) ==="
  kubectl get deployments -A
  echo ""
  echo "=== Recent events ==="
  kubectl get events -A --sort-by=.lastTimestamp | tail -20
}

## current context info
function k-current(){
  echo "Context:   $(kubectl config current-context)"
  echo "Namespace: $(knsc)"
  echo "Cluster:   $(kubectl config view --minify -o jsonpath='{.clusters[0].name}')"
  echo "User:      $(kubectl config view --minify -o jsonpath='{.users[0].name}')"
}

## namespace switcher (interactive)
function k-switch-ns(){
  local ns_list selected_ns
  ns_list=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')
  if [ -z "$ns_list" ]; then
    echo "No namespaces found."
    return 1
  fi
  echo "Available namespaces:"
  select selected_ns in $ns_list; do
    if [ -n "$selected_ns" ]; then
      kubectl config set-context --current --namespace="$selected_ns"
      echo "Switched to namespace: $selected_ns"
      return 0
    else
      echo "Invalid selection. Try again."
    fi
  done
}

## context switcher (interactive)
function k-switch-ctx(){
  local ctx_list selected_ctx
  ctx_list=$(kubectl config get-contexts -o name)
  if [ -z "$ctx_list" ]; then
    echo "No contexts found."
    return 1
  fi
  echo "Available contexts:"
  select selected_ctx in $ctx_list; do
    if [ -n "$selected_ctx" ]; then
      kubectl config use-context "$selected_ctx"
      echo "Switched to context: $selected_ctx"
      return 0
    else
      echo "Invalid selection. Try again."
    fi
  done
}

## nuke all resources in the current context (use with care)
function k-reset(){

  read -r -p "This will DELETE ALL resources in current context. Type DELETE to confirm: " confirmation
  [ "$confirmation" = "DELETE" ] || { echo "Cancelled."; return 0; }

  local system_ns='^(kube-system|kube-public|kube-node-lease|default)$'
  local ns

  for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
    if ! [[ "$ns" =~ $system_ns ]]; then
      echo "Deleting resources in namespace: $ns"
      kubectl delete all,cm,secret,ing,pvc,sa,role,rolebinding,netpol --all -n "$ns" --grace-period=0 --force
    fi
  done
}

## apply/clean current directory manifests (mirrors docker-clean)
function k-clean(){
  local project_dir="$(pwd)"

  if [ ! -f "$project_dir/kustomization.yaml" ] && [ ! -f "$project_dir/kustomization.yml" ] \
      && ! ls "$project_dir"/*.yaml >/dev/null 2>&1 && ! ls "$project_dir"/*.yml >/dev/null 2>&1; then
    echo "No kubernetes manifests (*.yaml, *.yml, kustomization.yaml) found in $project_dir"
    return 1
  fi

  if ! kubectl version --client >/dev/null 2>&1; then
    echo "kubectl is required: https://kubernetes.io/docs/tasks/tools/"
    return 1
  fi

  echo "1) Apply manifests (current directory)"
  echo "2) Delete all resources from these manifests"
  echo "q) Cancel"
  read -r -p "Choose [1/2/q]: " choice

  case "$choice" in
    1)
      if [ -f "$project_dir/kustomization.yaml" ] || [ -f "$project_dir/kustomization.yml" ]; then
        kubectl apply -k "$project_dir"
      else
        kubectl apply -f "$project_dir"
      fi
      ;;
    2)
      read -r -p "Type DELETE to remove this project's data: " confirmation
      [ "$confirmation" = "DELETE" ] || { echo "Cancelled."; return 0; }
      if [ -f "$project_dir/kustomization.yaml" ] || [ -f "$project_dir/kustomization.yml" ]; then
        kubectl delete -k "$project_dir"
      else
        kubectl delete -f "$project_dir"
      fi
      ;;
    q|Q|"")
      echo "Cancelled."
      return 0
      ;;
    *)
      echo "Invalid option."
      return 1
      ;;
  esac

  kubectl get all
}

## show resource consumption (mirrors docker-total-used-space)
function k-total-used-space(){
  echo "=== Node resources ==="
  kubectl top nodes
  echo ""
  echo "=== Pod resources (all namespaces) ==="
  kubectl top pods -A
  echo ""
  echo "=== Storage ==="
  kubectl get pvc -A
}

## decode a secret value
function k-secret-get(){
  local secret_name="$1"
  local key="$2"
  local ns
  ns=$(knsc)

  if [ -z "$secret_name" ] || [ -z "$key" ]; then
    echo "Usage: k-secret-get <secret-name> <key>"
    return 1
  fi

  kubectl get secret "$secret_name" -n "$ns" -o jsonpath="{.data.$key}" | base64 --decode
  echo ""
}

## tail logs of a deployment (selects the first pod)
function k-tail-deploy(){
  local deploy_name="$1"
  local ns
  ns=$(knsc)

  if [ -z "$deploy_name" ]; then
    echo "Usage: k-tail-deploy <deployment-name>"
    return 1
  fi

  local pod_name
  pod_name=$(kubectl get pod -n "$ns" -l "app=$deploy_name" -o jsonpath='{.items[0].metadata.name}')
  if [ -z "$pod_name" ]; then
    echo "No pod found for deployment $deploy_name in namespace $ns"
    return 1
  fi
  kubectl logs -f "$pod_name" -n "$ns"
}

## Enable verbose
function k-verbose() {
  export KUBECTL_COMMAND_HEADERS=1
}

## Disable verbose
function k-verbose-off() {
  unset KUBECTL_COMMAND_HEADERS
}


## how-to helpers
function how-to-create-k8s-secret-from-file(){
#  Create a secret from a file
#  kubectl create secret generic my-secret --from-file=path/to/file
  echo "kubectl create secret generic my-secret --from-file=path/to/file"
}

function how-to-create-k8s-secret-from-literal(){
#  Create a secret from a literal
#  kubectl create secret generic my-secret --from-literal=key=value
  echo "kubectl create secret generic my-secret --from-literal=key=value"
}

function how-to-port-forward(){
#  Forward a local port to a pod or service
#  kubectl port-forward pod/my-pod 8080:80
#  kubectl port-forward svc/my-service 8080:80
  echo "kubectl port-forward pod/<name> <local-port>:<remote-port>"
}

function how-to-get-sa-token(){
#  Get the token of a service account
#  kubectl get secret -n kube-system <secret-name> -o jsonpath='{.data.token}' | base64 --decode
  echo "kubectl get secret -n <namespace> <secret-name> -o jsonpath='{.data.token}' | base64 --decode"
}

function how-to-force-delete-stuck-pod(){
#  Force delete a stuck pod
#  kubectl delete pod <name> --grace-period=0 --force
  echo "kubectl delete pod <name> --grace-period=0 --force"
}

function how-to-scale-deployment(){
#  Scale a deployment
#  kubectl scale deployment/<name> --replicas=3
  echo "kubectl scale deployment/<name> --replicas=<n>"
}
