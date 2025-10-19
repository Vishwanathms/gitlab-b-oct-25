
# install metric server and flannel network

Install Metrics Server by applying its official manifest and verify with kubectl top, then install Flannel CNI by applying the upstream manifest and check the kube-flannel pods for readiness.[^1][^2][^3][^4][^5][^6]

### Prerequisites

- Ensure the cluster’s aggregation layer is enabled and kube-apiserver can reach Metrics Server and kubelets, or add the insecure TLS flag if your kubelet certs aren’t CA-signed.[^2]
- Confirm network plugin requirements and that nodes can pull images from official registries used by Metrics Server and Flannel.[^4][^1]


### Install Metrics Server

- Install the latest release: `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`.[^1][^2]
- If kubelet certs are self-signed, add the flag: `kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'`.[^7][^2]


### Verify Metrics Server

- Check pods: `kubectl -n kube-system get pods | grep metrics-server`. [^1]
- Test metrics after a short delay: `kubectl top nodes` and `kubectl top pods -A`.[^3][^8]


### Install Flannel CNI

- Apply the upstream manifest: `kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml`.[^5][^4]
- Flannel deploys in the kube-flannel namespace; confirm the DaemonSet and pods there.[^6][^4]


### Verify Flannel

- List Flannel pods: `kubectl -n kube-flannel get pods -o wide`.[^4][^6]
- Inspect the DaemonSet: `kubectl -n kube-flannel get ds kube-flannel-ds -o wide` and `kubectl -n kube-flannel describe ds kube-flannel-ds`.[^6]


### Notes and tips

- For high availability Metrics Server, use the HA manifest or Helm and consider enabling aggregator routing in kube-apiserver.[^2][^1]
- Metrics Server backs kubectl top and autoscaling APIs; if metrics are unavailable, revisit kubelet TLS and API aggregation settings.[^9][^3]
<span style="display:none">[^10][^11][^12][^13][^14][^15][^16][^17][^18][^19][^20]</span>

<div align="center">⁂</div>

[^1]: https://github.com/kubernetes-sigs/metrics-server

[^2]: https://kubernetes-sigs.github.io/metrics-server/

[^3]: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/

[^4]: https://github.com/flannel-io/flannel

[^5]: https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

[^6]: https://www.tkng.io/cni/flannel/

[^7]: https://dev.to/rslim087a/installing-metrics-server-238e

[^8]: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_top/kubectl_top_pod/

[^9]: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/

[^10]: https://discuss.kubernetes.io/t/how-can-i-install-metrics-server/23518

[^11]: https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

[^12]: https://resources.realtheory.io/docs/how-to-install-or-upgrade-the-metrics-server

[^13]: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdeployingmetricsserver.htm

[^14]: https://www.reddit.com/r/kubernetes/comments/15tx1nx/metrics_server_installation_never_works_without/

[^15]: https://www.vcluster.com/blog/how-to-set-up-metrics-server-an-easy-tutorial-for-k8s-users

[^16]: https://github.com/kubernetes-sigs/metrics-server/releases

[^17]: https://last9.io/blog/kubectl-top/

[^18]: https://www.eginnovations.com/documentation/Kubernetes/Installing-the-Metrics-Server.htm

[^19]: https://www.youtube.com/watch?v=0UDG52REs68

[^20]: https://stackoverflow.com/questions/52694238/kubectl-top-node-error-metrics-not-available-yet-using-metrics-server-as-he

