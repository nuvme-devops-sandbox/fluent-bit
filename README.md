# Fluent Bit

<img src="images/logo.png" width="100">

Fluent Bit is an open-source and lightweight log processor and forwarder designed for collecting, parsing, and shipping logs from various sources. It runs with minimal resource usage, making it suitable for high-performance environments, edge devices, and large-scale clusters.

Fluent Bit is part of the ecosystem developed by Treasure Data and the Fluentd community, delivering a more efficient and embedded-friendly engine while maintaining compatibility with modern logging pipelines. It provides flexible input/output plugins, structured log processing, and reliable delivery.

Fluent Bit is a graduated project under the Cloud Native Computing Foundation (CNCF). If your organization relies on distributed systems, observability pipelines, or container-orchestrated workloads, contributing to CNCF can help influence the direction of cloud-native logging and telemetry.

---

## Start

Before anything else, make sure the host has Docker installed.  
If not, install it:

```
sudo apt update
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
newgrp docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

If you need to collect logs directly from the host instead of Docker containers, use the single/ directory.

When starting from a Dockerfile, you must mount the correct log path inside the Fluent Bit container.
Example:

![alt text](images/single.png)


## Input Configuration

The Input section defines where Fluent Bit will listen for logs.

Two parameters must be adjusted:

Tag — label used in Grafana (example: nginx-error)

Path — log file path inside the container (example: /var/log/nginx/error.log)

Example:
![alt text](images/input.png)

## Filter Configuration

Example filter:
[FILTER]
    Name    record_modifier
    Match   nginx-error
    Record  log_type error

This adds metadata specifying the log type (e.g., error, access).

![alt text](images/image.png)

## Output Configuration

The Output section forwards all logs (after filters) to Loki.

If Loki runs internally: set the internal IP.

If Loki runs on another EC2 instance: use the EC2 IP.

If Loki runs inside a Kubernetes cluster: use HTTPS + TLS with a proper URL.

### Example output for Loki running in Kubernetes:

[OUTPUT]
    Name              loki
    Match             nginx-access
    Host              https://loki.nuvme
    Port              80
    URI               /loki/api/v1/push
    tls               On
    tls.verify        On
    line_format       key_value
    drop_single_key   On
    Labels            ec2_name=lab-kaua,log_group=nginx_access


## Logs Inside Containers

If you're collecting logs from Docker containers on the host, ensure Docker is installed:

```
sudo apt update
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
newgrp docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
You do not need to modify:

```
docker-compose.yml
parsers.conf
container_labels.lua
```

Only fluent-bit.conf needs adjustment.

![alt text](images/fluent-bit-conf.png)

Modify the Output section exactly like in the single-host configuration:

For Loki behind an ALB: use TLS.
For Loki running on an EC2 instance inside the same network: TLS is optional.