# Taint main node

```bash
kubectl taint nodes -l node-role.kubernetes.io/control-plane=true noapps=true:NoSchedule
```
