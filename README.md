# da-ssh-keychain

Centralized store for SSH **public** keys, synced across machines via `authorized_keys`.

> **Security Warning:** This repo contains **public keys only**. Never commit private keys.

## Key Naming Convention

```
keys/<machine>_<keytype>.pub
```

Examples:
- `keys/macbookpro_rsa.pub`
- `keys/homeserver_ed25519.pub`

## Adding a Key

```bash
cp ~/.ssh/id_ed25519.pub keys/$(hostname -s | tr '[:upper:]' '[:lower:]')_ed25519.pub
git add keys/ && git commit -m "Add key for $(hostname -s)" && git push
```

## Syncing Keys to a Machine

```bash
./scripts/sync.sh
```

This pulls the latest keys and installs them into `~/.ssh/authorized_keys` with deduplication and correct permissions.

## How It Works

1. Each machine's public key is stored in `keys/` with a descriptive filename
2. `scripts/sync.sh` concatenates all `.pub` files into `authorized_keys`
3. `.gitignore` aggressively blocks private key patterns from being committed
