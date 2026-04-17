# env-vault

Encrypted `.env` file manager for teams. Encrypt, share, and version-control environment variables without exposing secrets in plaintext.

## Requirements

- Node.js >= 18.0.0

## Installation

Install globally via npm:

```bash
npm install -g env-vault
```

## Usage

### Encrypt an existing `.env` file

```bash
env-vault encrypt .env --out .env.vault
```

### Decrypt a vault file

```bash
env-vault decrypt .env.vault --out .env
```

### Inject environment variables into a process

```bash
env-vault exec --vault .env.vault -- node server.js
```

### Show all stored keys (without values)

```bash
env-vault list --vault .env.vault
```

### Get help

```bash
env-vault --help
env-vault <command> --help
```

## How it works

`env-vault` uses [node-forge](https://github.com/digitalbazaar/forge) to AES-encrypt your `.env` file and stores the result in a `.env.vault` file that is safe to commit to version control. The encryption key is kept separately (e.g., in CI secrets or a shared password manager) and never written into the vault file itself.

## Dependencies

| Package | Purpose |
|---|---|
| `dotenv` | Parses `.env` format |
| `node-forge` | AES encryption/decryption |
| `yargs` | CLI argument parsing |

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit your changes and open a pull request against `main`

Please follow existing code style and add tests for new behaviour.

## License

MIT — see [LICENSE](LICENSE) for details.