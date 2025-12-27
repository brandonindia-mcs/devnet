#!/bin/bash

MAX_RETRIES=5
RETRY_COUNT=0
KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
DOWNLOAD_URL="https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
CHECKSUM_URL="https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl.sha256"
BINARY_FILE="kubectl"
CHECKSUM_FILE="kubectl.sha256"

# Loop to download and verify
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES: Downloading kubectl version ${KUBE_VERSION}..."
    curl -L -O "$DOWNLOAD_URL"
    curl -L -O "$CHECKSUM_URL"

    echo "Verifying checksum..."
    # The sha256sum command will exit with a non-zero status code on failure
    if echo "$(cat $CHECKSUM_FILE) $BINARY_FILE" | sha256sum --check; then
        echo "kubectl: OK. Verification successful!"
        # Make the binary executable and move it to your PATH
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        # sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        # rm $CHECKSUM_FILE # Clean up the checksum file
        echo "kubectl installed successfully in /usr/local/bin"
        kubectl version
        break
    else
        echo "kubectl: FAILED. Checksum mismatch. Retrying..."
        rm $BINARY_FILE $CHECKSUM_FILE # Remove potentially corrupted files
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 2 # Wait a bit before retrying
    fi
done

# echo "Failed to download and verify kubectl after $MAX_RETRIES attempts." >&2
