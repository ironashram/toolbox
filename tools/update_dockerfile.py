import re
import requests

urls = {
    "ANSIBLE_CORE_VERSION": "https://pypi.org/pypi/ansible-core/json",
    "OPENTOFU_VERSION": "https://api.github.com/repos/opentofu/opentofu/releases/latest",
    "KUBECTL_VERSION": "https://api.github.com/repos/kubernetes/kubernetes/releases/latest",
    "HELM_VERSION": "https://api.github.com/repos/helm/helm/releases/latest",
    "K3SUP_VERSION": "https://api.github.com/repos/alexellis/k3sup/releases/latest"
}


def get_latest_version(url, version_key):
    response = requests.get(url, timeout=30)
    data = response.json()
    if version_key == "ANSIBLE_CORE_VERSION":
        return data["info"]["version"]
    return data["tag_name"]


latest_versions = {key: get_latest_version(url, key) for key, url in urls.items()}

with open("Dockerfile", "r", encoding="utf8") as file:
    dockerfile_content = file.read()

updated = False
for key, version in latest_versions.items():
    new_content = re.sub(f'{key}="[^"]+"', f'{key}="{version}"', dockerfile_content)
    if new_content != dockerfile_content:
        updated = True
        dockerfile_content = new_content

if updated:
    with open("Dockerfile", "w", encoding="utf8") as file:
        file.write(dockerfile_content)
    print("Dockerfile updated with the latest versions.")
else:
    print("Dockerfile is already up to date.")
