# error

```
OldReplicaSets:  vish-python-app-55b57ddf7f (0/0 replicas created)

NewReplicaSet:   vish-python-app-77cc79d7d9 (3/3 replicas created)
Events:
Type    Reason             Age                From                   Message
-------------------------
Normal  ScalingReplicaSet  32m (x2 over 53m)  deployment-controller  Scaled up replica set vish-p
ython-app-55b57ddf7f to 1
Normal  ScalingReplicaSet  22m (x2 over 44m)  deployment-controller  Scaled down replica set vish
-python-app-55b57ddf7f to 0 from 1

Administrator@EC2AMAZ-1TOPCR2 MSYS ~/Documents
\$ kubectl -n 10-vish  get rs -l app=vish-python-app
NAME                         DESIRED   CURRENT   READY   AGE
vish-python-app-55b57ddf7f   0         0         0       31m
vish-python-app-77cc79d7d9   3         3         3       61m

```

The Deployment is currently served by ReplicaSet vish-python-app-77cc79d7d9 with 3/3 Ready pods, while the older vish-python-app-55b57ddf7f is scaled to 0, which indicates the rollout is complete and traffic is on the new ReplicaSet.  No action is required unless you want to verify the version or prune old ReplicaSets retained for rollback.

### What this shows

“NewReplicaSet: vish-python-app-77cc79d7d9 (3/3 replicas created)” means the Deployment’s active template is running and all desired pods are Ready.  “OldReplicaSets: vish-python-app-55b57ddf7f (0/0)” means the previous revision is kept for rollback but has no running pods.

### Verify rollout and image

- Check rollout completion: `kubectl -n 10-vish rollout status deploy/vish-python-app`
- List pods now serving the app: `kubectl -n 10-vish get pods -l app=vish-python-app -o wide`
- Confirm the image used by the new ReplicaSet: `kubectl -n 10-vish get rs vish-python-app-77cc79d7d9 -o=jsonpath='{.spec.template.spec.containers[*].image}{"\n"}'`


### Optional cleanup

- Remove zero-replica ReplicaSets safely: `kubectl -n 10-vish delete rs vish-python-app-55b57ddf7f` (keeps current 3/3 RS intact).
- Auto-prune future history: `kubectl -n 10-vish patch deploy vish-python-app -p '{"spec":{"revisionHistoryLimit":1}}'` (fewer old ReplicaSets retained).


### If this wasn’t the intended version

- Inspect revision history: `kubectl -n 10-vish rollout history deploy/vish-python-app`
- Roll back to a specific revision if needed: `kubectl -n 10-vish rollout undo deploy/vish-python-app --to-revision=<N>`



