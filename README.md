[![Weekly Update](https://github.com/ironashram/toolbox/actions/workflows/weekly-update.yml/badge.svg)](https://github.com/ironashram/toolbox/actions/workflows/weekly-update.yml)
[![Docker Image Build](https://github.com/ironashram/toolbox/actions/workflows/docker-image.yml/badge.svg)](https://github.com/ironashram/toolbox/actions/workflows/docker-image.yml)

# ToolBox

Docker image containing multiple automation tools.

## Packages

| Tool      | Project Link                             |
|:----------|:-----------------------------------------|
| Ansible   | https://github.com/ansible/ansible       |
| OpenTofu  | https://github.com/opentofu/opentofu     |
| Kubectl   | https://github.com/kubernetes/kubernetes |
| Helm      | https://github.com/helm/helm             |
| K3sup     | https://github.com/alexellis/k3sup       |


## Usage

```sh
docker pull ghcr.io/ironashram/toolbox:latest
```


## Projects Using This Image

- [kub1k](https://github.com/ironashram/kub1k)
- [commstack](https://github.com/ironashram/commstack)
- [metapac](https://github.com/ironashram/metapac)
