#!/bin/bash

hour=$(date +%H)
if (( hour >= 8 && hour < 20 )); then
  replicas=5
else
  replicas=2
fi

kubectl scale --replicas=$replicas deployment/users-api
kubectl scale --replicas=$replicas deployment/shifts-api