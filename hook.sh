#!/bin/bash

#set -x

source /shell_lib.sh

function __config__() {
  cat << EOF
    configVersion: v1
    kubernetes:
    - name: nodes
      apiVersion: v1
      kind: Node
      labelSelector:
        matchLabels:
          node-role.kubernetes.io/egress: "true"
      jqFilter: |
        {
          name: .metadata.name,
          taints: .spec.taints
        }
      group: main
      keepFullObjectsInMemory: false
      executeHookOnEvent: ["Modified"]
EOF
}

function __main__() {
  for i in $(seq 0 "$(context::jq -r '(.snapshots.nodes | length) - 1')"); do
    node_name="$(context::jq -r '.snapshots.nodes['"$i"'].filterResult.name')"
    taints="$(context::jq -r '.snapshots.nodes['"$i"'].filterResult.taints')"
    if echo $taints | grep -v "node.kubernetes.io/unreachable"; then
      export egress_ready=$node_name
      for i in $(kubectl get ciliumegressgatewaypolicies.cilium.io -o name); do
        kubectl get $i -o yaml | yq 'del(.metadata.annotations, .metadata.creationTimestamp, .metadata.generation, .metadata.resourceVersion, .metadata.uid)' | yq '.spec.egressGateway.nodeSelector.matchLabels."kubernetes.io/hostname" = env(egress_ready)' | kubectl apply -f -
      done
      break
    fi
  done
}

hook::run "$@"
