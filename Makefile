ARCH := $(shell uname -i)

ifeq ($(ARCH),x86_64)
        URL += http://archive.ubuntu.com/ubuntu
endif
ifeq ($(ARCH),aarch64)
        URL += http://ports.ubuntu.com/ubuntu-ports
endif

.PHONY: node gatsby hugo go python ecs all vm
node:
	incus image rm node || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="node"  node.yaml

gatsby:
	incus image rm gatsby || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="gatsby"  gatsby.yaml

hugo:
	incus image rm hugo || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="hugo"  hugo.yaml

go:
	incus image rm go || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="go"  go.yaml

python:
	incus image rm python || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="python" python.yaml

ecs:
	incus image rm ecs || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="ecs" ecs.yaml

ecs-vm:
	incus image rm ecs-vm || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="ecs-vm" --vm ecs.yaml

ubuntu:
	incus image rm ubuntu || true
	sudo distrobuilder build-incus -o image.architecture=$(ARCH) -o image.release=noble -o image.variant=cloud -o source.url=$(URL) --import-into-incus="ubuntu" ubuntu.yaml

all: node gatsby hugo go python ecs ubuntu

vm: ecs-vm