```
unexpected status code https://registry-1.docker.io/v2/library/python/manifests/sha256:a773107406cd3dc167cca6f91c82c2c5587ac6e84e240baa6dfc8599cd849d5e: 429 Too Many Requests - Server message: toomanyrequests: You have reached your unauthenticated pull rate limit. https://www.docker.com/increase-rate-limit ------ > [internal] load metadata for docker.io/library/python:3.10-slim: ------ Dockerfile:1 -------------------- 1 | >>> FROM python:3.10-slim 2 | 3 | WORKDIR /app -------------------- ERROR: failed to solve: python:3.10-slim: failed to copy: httpReadSeeker: failed open: unexpected status code https://registry-1.docker.io/v2/library/python/manifests/sha256:a773107406cd3dc167cca6f91c82c2c5587ac6e84e240baa6dfc8599cd849d5e: 429 Too Many Requests - Server message: toomanyrequests: You have reached your unauthenticated pull rate limit. https://www.docker.com/increase-rate-limit Cleaning up project directory and file based variables 00:00 ERROR: Job failed: exit code 1
```

```
The error message you’re seeing:

429 Too Many Requests - Server message: toomanyrequests: You have reached your unauthenticated pull rate limit.


means Docker Hub has rate-limited your IP because you’re pulling public images (like python:3.10-slim) without authentication.

Let’s go step-by-step on how to fix this.
```

```
Root Cause
Docker Hub applies limits to anonymous pulls:
Unauthenticated users: ~100 pulls per 6 hours (per IP)
Authenticated users: ~200 pulls per 6 hours per account
This often happens in CI/CD pipelines (e.g., GitLab, Jenkins) or shared networks (e.g., corporate VPNs or cloud runners).
```
