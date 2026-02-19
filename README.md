# envswitch

Quickly switch between `.env` files in your project.

## Usage

```bash
# Create your .envs directory with files like:
# .envs/.env.staging
# .envs/.env.prod
# .envs/.env.local

# List available environments
envswitch --list

# Switch to an environment
envswitch staging
envswitch prod
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/8xu/envswitch/main/install.sh | bash
```

Or manually:

1. Download the binary for your platform from Releases
2. Add to PATH
3. Run `envswitch --help`
