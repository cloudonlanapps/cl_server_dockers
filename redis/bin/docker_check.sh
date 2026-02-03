#!/bin/bash

################################################################################
# Ensure Docker Desktop is running and engine is ready
################################################################################

ensure_docker_running() {

    # Check if docker engine is ready
    docker_ready() {
        docker info >/dev/null 2>&1
    }

    # Already ready?
    if docker_ready; then
        echo "[✓] Docker is running"
        return 0
    fi

    echo "[*] Starting Docker..."
    OS="$(uname -s)"
    if [ "$OS" = "Darwin" ]; then
        # macOS: launch Docker.app
        open -a Docker
    elif [ "$OS" = "Linux" ]; then
        # Linux: Check if running via systemctl first to avoid permission confusion
        if command -v systemctl >/dev/null 2>&1; then
            if systemctl is-active --quiet docker; then
                echo "[!] Docker service is running, but 'docker info' failed."
                echo "    This is likely a permission issue (user not in 'docker' group)."
                return 1
            fi
            sudo systemctl start docker
        elif command -v service >/dev/null 2>&1; then
             if service docker status >/dev/null 2>&1; then
                echo "[!] Docker service is running, but 'docker info' failed (permissions?)."
                return 1
             fi
            sudo service docker start
        else
            echo "[!] Could not detect systemctl or service. Please start Docker manually."
        fi
    else
        echo "[!] OS not supported for auto-start. Please start Docker manually."
    fi

    echo "[*] Waiting for Docker to initialize…"

    # Maximum wait: 2 minutes
    local timeout=120
    local waited=0

    # Poll every 3 seconds
    while ! docker_ready; do
        sleep 3
        waited=$((waited + 3))

        echo "    → Docker not ready yet... ($waited/$timeout sec)"

        if [ $waited -ge $timeout ]; then
            echo "[✗] ERROR: Docker did not start within $timeout seconds"
            return 1
        fi
    done

    echo "[✓] Docker is ready"
    return 0
}

ensure_docker_running
