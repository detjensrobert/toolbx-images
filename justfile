image_repo := "ghcr.io/detjensrobert/toolbx-images"

# build the default images
build-usual: (build "arch") (build "zed")
push-usual: (push "arch") (push "zed")

# build a single image
build name:
    podman build --squash --format=oci --pull=always -t {{image_repo}}:{{name}} {{name}}

# push a single image (builds it first)
push name: (build name)
    podman push {{image_repo}}:{{name}} --compression-format zstd:chunked --compression-level 20
