#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:DaDevChia/da-ssh-keychain.git"
REPO_DIR="${DA_SSH_KEYCHAIN_DIR:-$HOME/.da-ssh-keychain}"
SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

# Clone or pull the repo
if [ -d "$REPO_DIR/.git" ]; then
    echo "Pulling latest keys..."
    git -C "$REPO_DIR" pull --quiet
else
    echo "Cloning keychain repo..."
    git clone --quiet "$REPO_URL" "$REPO_DIR"
fi

# Ensure .ssh directory exists with correct permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Collect all .pub files
KEYS_DIR="$REPO_DIR/keys"
pub_files=("$KEYS_DIR"/*.pub)

if [ ! -e "${pub_files[0]}" ]; then
    echo "No .pub files found in $KEYS_DIR"
    exit 0
fi

# Validate that we only process .pub files
for f in "${pub_files[@]}"; do
    if [[ "$f" != *.pub ]]; then
        echo "WARNING: Skipping non-.pub file: $f"
        continue
    fi
done

# Build new authorized_keys with deduplication
# Preserve any existing keys not from this repo, then append repo keys
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Start with existing authorized_keys if present
if [ -f "$AUTH_KEYS" ]; then
    cp "$AUTH_KEYS" "$temp_file"
fi

# Append all repo keys
for f in "${pub_files[@]}"; do
    cat "$f" >> "$temp_file"
done

# Deduplicate and write
sort -u "$temp_file" > "$AUTH_KEYS"

chmod 600 "$AUTH_KEYS"

key_count=$(wc -l < "$AUTH_KEYS" | tr -d ' ')
echo "Synced $key_count unique keys to $AUTH_KEYS"
