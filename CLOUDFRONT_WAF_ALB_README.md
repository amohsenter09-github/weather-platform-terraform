### CloudFront + WAF + ALB (Ingress) – full explanation (with diagrams)

### What you built (high level)

**Request flow (public internet → your pods):**

#### Happy path (allowed)

`Browser`
→ **Route53** (`cdn.infra-ai-art.delivery`)
→ **CloudFront Distribution** (public entrypoint)
→ **WAFv2 Web ACL** *(filters/blocks bad traffic)*
→ **Origin DNS** (`origin.infra-ai-art.delivery`)
→ **ALB** (created by AWS Load Balancer Controller from your Kubernetes Ingress)
→ `Kubernetes Service`
→ `Pods`

#### Blocked paths (what we intentionally prevent)

**1) Direct internet → ALB (blocked by Security Group)**

`Browser`
→ `k8s-…elb.amazonaws.com` *(raw ALB DNS)*
→ ❌ **Blocked at ALB Security Group** (only CloudFront origin-facing IP ranges allowed)

**2) Direct internet → ALB with forged Host header (still blocked)**

`Browser`
→ `k8s-…elb.amazonaws.com` + `Host: origin.infra-ai-art.delivery`
→ ❌ **Still blocked at Security Group** (Host headers can be forged; SG cannot)

**3) Direct internet → origin DNS (also blocked)**

`Browser`
→ `origin.infra-ai-art.delivery`
→ ❌ **Blocked at ALB Security Group**

### Locking the ALB to CloudFront only (recommended)

**Goal:** block direct internet traffic to the ALB, and only allow requests that come from CloudFront.

**Flow:** Internet → ALB (blocked) | Internet → CloudFront → ALB (allowed)

How it works:
- Create an ALB Security Group that allows inbound **only** from the AWS-managed prefix list:
  - `com.amazonaws.global.cloudfront.origin-facing`
- Attach that security group to the ALB created by the Kubernetes Ingress (via annotations).
- Result: even if someone learns the ALB DNS name, they cannot reach it directly.

In this repo, Terraform outputs:
- `alb_cloudfront_only_security_group_id`

Then update your Ingress annotations (example):

- `alb.ingress.kubernetes.io/security-groups: <alb_cloudfront_only_security_group_id>`
- `alb.ingress.kubernetes.io/manage-backend-security-group-rules: "true"`

Optional hardening:
- Configure CloudFront to send a custom origin header, and require that header in the Ingress/app.

### Why this setup
- **CloudFront**: global edge caching/acceleration + a stable public endpoint.
- **WAF (on CloudFront)**: blocks common attacks before traffic reaches your ALB/cluster.
- **ALB (Ingress)**: routes HTTP(S) traffic into Kubernetes based on host/path rules.

### Important AWS details
- **CloudFront custom domain certificates must be in `us-east-1`** (ACM).
- **WAF for CloudFront is global but created with `scope = CLOUDFRONT`** (typically managed via `us-east-1` API).
- **ALB + EKS live in your workload region** (here: `eu-west-1`).

### DNS setup (two different names on purpose)
We use two names so we can keep the ALB as an **origin-only** endpoint and make CloudFront the **only public entrypoint**.

- **Public CloudFront alias (users hit this):**
  - `cdn.infra-ai-art.delivery` → Route53 **A Alias** → CloudFront distribution domain
- **Origin alias (CloudFront hits this):**
  - `origin.infra-ai-art.delivery` → created/managed by ExternalDNS → points at the ALB

Important: your Kubernetes Ingress must match the origin hostname:
- Ingress `spec.rules[].host` should be `origin.infra-ai-art.delivery`

If the Ingress host doesn’t match, the ALB returns **404** (host-based routing).

### What to expect operationally
- Creating/updating CloudFront can take **10–30 minutes** to fully propagate.
- WAF blocks will show up in **WAF sampled requests / metrics** (CloudWatch).
- If CloudFront is in front, you’ll usually terminate TLS at **CloudFront** and forward to the ALB as **HTTPS** (recommended).

### TLS/certificates (who needs which cert, where)

**1) CloudFront (public)**
- Cert location: **ACM in `us-east-1`**
- Covers: `cdn.infra-ai-art.delivery`

**2) ALB (origin)**
- Cert location: **ACM in `eu-west-1`**
- Covers: `origin.infra-ai-art.delivery`

This lets CloudFront use **`https-only`** to the origin without certificate mismatch.

### Where to look when debugging
- **CloudFront**: distribution events + access logs (if enabled)
- **WAF**: sampled requests + rule metrics
- **ALB**: target group health + listener rules
- **Kubernetes**:
  - `kubectl -n kube-system logs deploy/aws-load-balancer-controller`
  - `kubectl -n external-dns logs deploy/external-dns`

