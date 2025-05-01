# Makefile for Docker Buildx Operations

# === Variables ===
# --- Customizable ---
# Override these on the command line like: make build IMAGE_NAME=my-app TAG=beta MOPIDY_RELEASE=3.5.0
# Docker registry/namespace (e.g., docker.io/username, ghcr.io/org, or 'local' for local builds)
REGISTRY ?= local
# Name of the image
IMAGE_NAME ?= mopidy
# Tag for the image
TAG ?= latest
#
# Specific build argument for Mopidy release
MOPIDY_RELEASE ?= 3.4.2

# --- Internal/Derived ---

# You usually don't need to override these directly
FULL_IMAGE_NAME = $(REGISTRY)/$(IMAGE_NAME):$(TAG)
# Predictable container name
CONTAINER_NAME = $(IMAGE_NAME)-container-$(TAG)
BUILD_CONTEXT ?= .
DOCKERFILE ?= $(BUILD_CONTEXT)/Dockerfile # Path to the Dockerfile

# === Targets ===
.PHONY: all build run exec stop logs clean help

# Default target when running 'make'
all: build

# Build the Docker image using buildx
# --load: Ensure the image is available in the local Docker daemon storage after build
# Add other buildx flags as needed (e.g., --platform linux/amd64,linux/arm64)
build:
	@echo "--- Building image: $(FULL_IMAGE_NAME) ---"
	docker buildx build \
		$(BUILD_CONTEXT) \
		--load \
		--tag $(FULL_IMAGE_NAME) \
		--build-arg MOPIDY_RELEASE=$(MOPIDY_RELEASE) \
		--file $(DOCKERFILE)
	@echo "--- Build complete: $(FULL_IMAGE_NAME) ---"

# Run the container in detached mode
# --rm: Automatically remove the container when it exits
# NOTE: Add necessary -p (port mappings) and -v (volume mounts) for your specific application!
run:
	@echo "--- Running container $(CONTAINER_NAME) from image $(FULL_IMAGE_NAME) ---"
	docker run -d --rm \
		--name $(CONTAINER_NAME) \
		$(FULL_IMAGE_NAME)
	@echo "--- Container $(CONTAINER_NAME) started. Use 'make logs' or 'make stop' ---"

# Execute an interactive shell (sh) inside the running container
exec:
	@echo "--- Executing sh inside container $(CONTAINER_NAME) ---"
	docker exec -it $(CONTAINER_NAME) sh

# Stop the running container
stop:
	@echo "--- Stopping container $(CONTAINER_NAME) ---"
	docker stop $(CONTAINER_NAME) || echo "Container already stopped or not found."

# Follow logs of the running container
logs:
	@echo "--- Following logs for container $(CONTAINER_NAME) (Ctrl+C to stop) ---"
	docker logs -f $(CONTAINER_NAME)

# Clean: Stop container and remove image (Use with caution!)
# If run fails to remove container (e.g., not run with --rm), this helps clean up.
clean: stop
	@echo "--- Removing container $(CONTAINER_NAME) if it exists ---"
	-docker rm $(CONTAINER_NAME) # Use '-' to ignore errors if container doesn't exist
	@echo "--- Removing image $(FULL_IMAGE_NAME) ---"
	-docker rmi $(FULL_IMAGE_NAME) # Use '-' to ignore errors if image doesn't exist
	@echo "--- Clean up finished ---"

# Display help
help:
	@echo "Makefile for Docker Operations ($(IMAGE_NAME))"
	@echo ""
	@echo "Usage: make [TARGET] [VAR=VALUE ...]"
	@echo ""
	@echo "Targets:"
	@echo "  all          Build the image (default)."
	@echo "  build        Build the Docker image using buildx."
	@echo "  run          Run a container from the built image."
	@echo "  exec         Execute an interactive 'sh' shell in the running container."
	@echo "  stop         Stop the running container."
	@echo "  logs         Follow the logs of the running container."
	@echo "  clean        Stop and remove the container, then remove the image."
	@echo "  help         Show this help message."
	@echo ""
	@echo "Variables:"
	@echo "  REGISTRY       Registry/namespace (default: $(REGISTRY))"
	@echo "  IMAGE_NAME     Image name (default: $(IMAGE_NAME))"
	@echo "  TAG            Image tag (default: $(TAG))"
	@echo "  MOPIDY_RELEASE Build argument value (default: $(MOPIDY_RELEASE))"
	@echo "  CONTAINER_NAME Name for the running container (default: $(CONTAINER_NAME))"
	@echo "  BUILD_CONTEXT  Docker build context directory (default: $(BUILD_CONTEXT))"
	@echo "  DOCKERFILE     Path to Dockerfile (default: $(DOCKERFILE))"
	@echo ""
	@echo "Example:"
	@echo "  make build TAG=dev MOPIDY_RELEASE=3.5.0"
	@echo "  make run TAG=dev"
	@echo "  make exec TAG=dev"
	@echo "  make clean REGISTRY=myrepo IMAGE_NAME=my-mopidy TAG=dev"
	@echo ""
