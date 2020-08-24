# Demonstration dockerfile

## Warnings

**This docker file is meant for demonstration only - do NOT use in production!**

Using proper Debian or a derived distribution (in a VM or on bare metal) is recommended.

**Do NOT base another docker image off this one!**

This image removes protection that would be needed for creating derived images.
Frankly, you shouldn't need it. The whole point of this project is to never need Docker.
If you feel like creating an image you most likely want to contribute a package into the repository instead.

## How to use

In host system (you may need `sudo`)

```
docker build -t cadr:latest - < Dockerfile
docker run -d --name cadr --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup:ro cadr:latest
docker exec -it cadr bash
```

In the docker console

```
apt update
apt install bitcoin-regtest # ...
```
