## Description

It is simple k8s operator based on [Flant shell-operator](https://github.com/flant/shell-operator) for egress HA-mode of Cilium.

[Cilium](https://cilium.io/) has an awesome feature called [egress](https://docs.cilium.io/en/stable/network/egress-gateway/), that allows you to redirect outbound traffic form specific pods to specific nodes(via labels). 

As you know, in Kubernetes nodes can appear and disappear just like pods. But you can allocate a pool of nodes for outbound traffic for some(or all) apps with this Cilium feature. This is a very common case, for example, if you need to send a WhiteList IPs to your third partners. 

Unfortunately, [community version of Cilium doesn't have HA-mode for egress](https://github.com/cilium/cilium/issues/18230).

This operator implements a simple HA-mode for egress. It is assumed that you have 2 "low", empty" nodes for egress (similar to ingress) with label `node-role.kubernetes.io/egress: "true"`. Let's say that by default the node for egress outbound traffic is called egress-1. If this node goes into state "Not Ready", this operator will override all manifests for egress and replace this node there with reserve egress-2. 

This process takes about 30s.

## Deployment

- build image & push to your registry

- edit manifests in `operator.yaml`

- `kubectl -n <namespace> apply -f operator.yaml`

- exapmle dir contains example maninefest for `CiliumEgressGatewayPolicy`
