# Devops-bootcamp-project

A three-node AWS environment provisioned end to end with Terraform and configured
with Ansible: a public app server running a containerized build, a private
controller that drives every playbook, and a monitoring stack reachable with no
inbound port ever opened.

## Live links

| | |
|---|---|
| Application | [https://web.arifbhrn.com](https://web.arifbhrn.com/) |
| Monitoring (Grafana) | [https://monitoring.arifbhrn.com](https://monitoring.arifbhrn.com/d/ad2vbvb/armada-node-overview?from=now-15m&to=now&timezone=browser&refresh=30s) |
| Source page | [https://arifbhrn.github.io/devops-bootcamp-project/](https://github.com/Arifbhrn/devops-bootcamp-project) |
| Overview page | https://demo.arifbhrn.com/ |

## Stack

Terraform · Ansible · Docker Compose · Amazon ECR · Prometheus · Grafana ·
Cloudflare Tunnel · AWS SSM Parameter Store

## Repository layout

```
.
├── app/            application source + Dockerfile
├── terraform/      VPC, subnets, security groups, IAM, the three EC2 modules
├── ansible/        playbooks, inventory template, docker-compose files
└── index.html      status page served via GitHub Pages
```
## Running this yourself

1. Store the Cloudflare tunnel token once, before the first apply. The parameter name below isn't fixed, it just has to        match `tunnel_parameter` in `ansible/playbook-stack.yaml` wherever you actually run this from.
   ```
      aws ssm put-parameter \
     --name /devops-bootcamp-project/tunnel-token \
     --type SecureString \
     --value "<your tunnel token>"
   ```
2. Terraform apply — provisions the VPC, subnets, security groups, IAM role, and all three EC2 instances. The controller's     `user_data` `(controller-setup.sh)` installs Ansible and the geerlingguy.docker Galaxy role, clones this repo, and          generates inventory.ini from the instances real private IPs at boot.
   
3. SSH into the controller as ssm-user and run the playbooks in order:
   ```
    playbook-docker.yaml
    playbook-exporter.yaml
    playbook-stack.yaml
    playbook-app.yaml
   ```
   or alternatively, run all four automatically with a single command
   ```
    ansible-playbook site.yaml
   ```
4. From here on: edit, push, re-run the playbook. Nothing changes unless the
   underlying files actually changed, so running it again with no edits is
   safe and does nothing `changed=0`.

### Secrets

Nothing sensitive is committed to this repo. The Cloudflare tunnel token is
stored in AWS SSM Parameter Store (`SecureString`) and fetched live by the
playbook at run time. SSH keys and deploy keys are injected into the
controller via Terraform's `templatefile()`, not stored in version control.

## Screenshots

`Infratify Ship`

<img width="1042" height="560" alt="image" src="https://github.com/user-attachments/assets/e1395d5b-1ad8-445a-8e55-f772c2f9d005" />

---

`Grafana Dashboard`

<img width="875" height="883" alt="image" src="https://github.com/user-attachments/assets/cbf2f021-6225-4681-b690-1df88c4134fc" />



