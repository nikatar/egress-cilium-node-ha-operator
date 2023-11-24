FROM ghcr.io/flant/shell-operator:v1.2.0

RUN apk add --no-cache yq

ADD hook.sh /hooks
