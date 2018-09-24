ifeq ($(origin VERSION), undefined)
	VERSION != git rev-parse --short HEAD
endif

PREFIX=/usr/local

HOST_GOOS=$(shell go env GOOS)
HOST_GOARCH=$(shell go env GOARCH)
# GOOS=windows GOARCH=386 

NAME=vedecom-ukko
REPO_PATH=bitbucket.com/glenux-corp/vedecom-ukko
BUILD_DIR=$(shell pwd)/_build
INSTALL_DIR=$(PREFIX)/bin
SHARE_DIR=$(PREFIX)/share/$(NAME)

all: build

build: vendor  ## build executable
	@mkdir -p "$(BUILD_DIR)"
	# go build -i ./...
	# GOBIN="$(BUILD_DIR)" go install ./...
	for binary in "./cmd"/* ; do \
		name="$$(basename "$$binary")" ; \
		go build -i "$$binary" || exit 1 ; \
		if [ -f "$$name.exe" ]; then \
			mv "$$name.exe" "$(BUILD_DIR)/$$name.exe" || exit 1 ; \
		else \
			mv "$$name" "$(BUILD_DIR)/$$name" || exit 1 ; \
		fi ; \
	done


install:
	install -g root -o root -m 644 -D Procfile "$(SHARE_DIR)"/Procfile
	for binary in "$(BUILD_DIR)"/* ; do \
		name="$$(basename "$$binary")" ; \
		install -g root -o root -m 0755 -D $$binary "$(INSTALL_DIR)"/$$name || exit 1 ; \
	done
	echo "INSTALL_DIR=$(INSTALL_DIR)" > "$(SHARE_DIR)"/env.production

uninstall:
	for binary in "$(BUILD_DIR)"/* ; do \
		name="$$(basename "$$binary")" ; \
		rm -f "$(INSTALL_DIR)/$$name" || exit 1 ; \
	done
	rm -fr "$(SHARE_DIR)

vendor: ## prepare build tools & vendor dependencies
	go mod download
.PHONY: vendor

help: ## print this help
	@echo "Usage: make <target>"
	@echo ""
	@echo "With one of following targets:"
	@awk 'BEGIN {FS = ":.*?## "} \
	  /^[a-zA-Z_-]+:.*?## / \
	  { sub("\\\\n",sprintf("\n%22c"," "), $$2); \
	    printf("\033[36m%-20s\033[0m %s\n", $$1, $$2); \
	  }' $(MAKEFILE_LIST)

clean: ## remove build artifacts
	rm -rf "$(BUILD_DIR)"/*

