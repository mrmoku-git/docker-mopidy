# How to Use the Makefile:

1.  **Save:** Save the code above as `Makefile` in your project directory (where your `Dockerfile` is).
2.  **Build:**
    *   `make build` (uses defaults: `local/mopidy:latest`, `MOPIDY_RELEASE=3.4.2`)
    *   `make build TAG=testing MOPIDY_RELEASE=3.5.0` (builds `local/mopidy:testing` with `MOPIDY_RELEASE=3.5.0`)
    *   `make build REGISTRY=myregistry.com/myorg IMAGE_NAME=cool-app TAG=v1.0` (builds `myregistry.com/myorg/cool-app:v1.0`)
3.  **Run:**
    *   `make run` (runs the container named `mopidy-container-latest` from `local/mopidy:latest`)
    *   `make run TAG=testing` (runs the container named `mopidy-container-testing` from `local/mopidy:testing`)
    *   **Remember:** You might need to edit the `run` target in the `Makefile` to add specific port mappings (`-p`) or volume mounts (`-v`) required by your Mopidy setup.
4.  **Exec:**
    *   `make exec` (executes `sh` in `mopidy-container-latest`)
    *   `make exec TAG=testing` (executes `sh` in `mopidy-container-testing`)
    *   Ensure the corresponding container is running (`make run` first).
5.  **Stop:**
    *   `make stop`
    *   `make stop TAG=testing`
6.  **Logs:**
    *   `make logs`
    *   `make logs TAG=testing`
7.  **Clean:**
    *   `make clean` (stops/removes container `mopidy-container-latest` and image `local/mopidy:latest`)
    *   `make clean TAG=testing`
8.  **Help:**
    *   `make help` (shows available commands and variables)

This Makefile provides a flexible base for managing your Docker workflow with buildx.
