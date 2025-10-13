Generate a new token

If kubeadm token list shows nothing or tokens have expired:

```
sudo kubeadm token create --print-join-command
```

✅ Output example:

```
kubeadm join 192.168.56.101:6443 --token 8f8sjd.k2s9f9k8d93ks93l \
  --discovery-token-ca-cert-hash sha256:4c39d28f8e35d7c9b97f46c4b5b7a2e3a6f4d1a6c6b0b9e2c3f0f01aab2f1c31
```

That’s your ready-to-run command for all worker nodes.