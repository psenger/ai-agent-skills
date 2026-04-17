<div align="center">

# env-vault

**Encrypt, share, and manage `.env` files safely across your team.**

[![CI](https://github.com/psenger/env-vault/actions/workflows/ci.yml/badge.svg)](https://github.com/psenger/env-vault/actions)
[![npm](https://img.shields.io/npm/v/env-vault.svg)](https://www.npmjs.com/package/env-vault)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

[Features](#features) • [Quick start](#quick-start) • [Installation](#installation) • [Usage](#usage) • [Configuration](#configuration)

</div>

---

env-vault is a CLI tool that encrypts `.env` files so teams can commit them to
version control without exposing secrets. Each developer or environment gets its
own key; env-vault handles the encryption and decryption, so the workflow is a
single command instead of a manual secret-sharing ritual.

## Features

- **AES encryption via node-forge.** Secrets are encrypted before they ever touch
  disk or version control.
- **Team-friendly key management.** Issue per-developer or per-environment keys
  without sharing raw secrets.
- **Drop-in dotenv compatibility.** Decrypted output loads with the same
  `dotenv` conventions your app already uses.
- **No external service required.** Keys and ciphertext stay in your repo and
  your key store — no third-party vault subscription needed.

## Installation

```bash
npm install -g env-vault
```

Requires Node 18 or later.

## Quick start

Encrypt your `.env` file and commit the result:

```bash
env-vault encrypt --in .env --out .env.vault --key "$(cat team.key)"
git add .env.vault
git commit -m "chore: update encrypted env"
```

Decrypt on another machine (or in CI):

```bash
env-vault decrypt --in .env.vault --out .env --key "$ENV_VAULT_KEY"
```

The decrypted `.env` is standard dotenv format — load it with your existing
`require('dotenv').config()` call.

## Usage

### Encrypt

```bash
env-vault encrypt --in .env --out .env.vault --key <key>
```

| Flag | Description |
|---|---|
| `--in` | Path to the plaintext `.env` file |
| `--out` | Path to write the encrypted vault file |
| `--key` | Encryption key (hex string or path to key file) |

### Decrypt

```bash
env-vault decrypt --in .env.vault --out .env --key <key>
```

| Flag | Description |
|---|---|
| `--in` | Path to the encrypted vault file |
| `--out` | Path to write the decrypted `.env` file |
| `--key` | Decryption key matching the one used to encrypt |

### Generate a key

```bash
env-vault keygen
```

Prints a fresh random key to stdout. Pipe it to a file or store it in your
secrets manager.

Run `env-vault --help` for the full flag reference.

## Configuration

env-vault reads the decryption key from the `ENV_VAULT_KEY` environment variable
when `--key` is not passed on the command line. This lets CI pipelines supply the
key without it appearing in shell history:

```bash
export ENV_VAULT_KEY="$(aws secretsmanager get-secret-value \
  --secret-id env-vault-key --query SecretString --output text)"

env-vault decrypt --in .env.vault --out .env
```

## Development

```bash
git clone https://github.com/psenger/env-vault.git
cd env-vault
npm install
npm test
```

Pull requests are welcome. Open an issue first for larger changes so we can
agree on direction before you invest the time.

## License

MIT — see [LICENSE](./LICENSE) for details.

---

<div align="center">

**Stop emailing secrets. Commit the vault, share the key.**

[Report Bug](https://github.com/psenger/env-vault/issues) • [Request Feature](https://github.com/psenger/env-vault/issues) • [npm package](https://www.npmjs.com/package/env-vault)

</div>