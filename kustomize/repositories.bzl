load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_kustomize_runtimes = {
    "2.0.3": [
        {
            "os": "linux",
            "arch": "amd64",
            "sha256": "a04d79a013827c9ebb0abfe9d41cbcedf507a0310386c8d9a7efec7a36f9d7a3",
        },
        {
            "os": "darwin",
            "arch": "amd64",
            "sha256": "da4e4b7fe785a25997a0c34708faa6bce13d7847fc4d19d9ce46a0794098ba9b",
        },
    ],
}

def kustomize_tools():
    for kustomize_version, platforms in _kustomize_runtimes.items():
        for platform in platforms:
            github_releases_download = "https://github.com/kubernetes-sigs/kustomize/releases/download/v{version}/kustomize_{version}_{os}_{arch}".format(
                version = kustomize_version,
                **platform
            )
            http_file(
                name = "kustomize_runtime_{os}_{arch}".format(**platform),
                urls = [github_releases_download],
                sha256 = platform["sha256"],
            )
