# v-bump

Semantic version bumping for npm packages. Parses git commit messages or accepts CLI arguments.

[![npm version](https://img.shields.io/npm/v/@mmpg-soft/v-bump.svg)](https://www.npmjs.com/package/@mmpg-soft/v-bump)
[![npm downloads](https://img.shields.io/npm/dm/@mmpg-soft/v-bump.svg)](https://www.npmjs.com/package/@mmpg-soft/v-bump)

## Installation

```bash
npm install @mmpg-soft/v-bump
```

## Quick Start

```bash
# Bump patch version
v-bump -s patch

# Bump minor version
v-bump -s minor

# Bump major version
v-bump -s major
```

## Usage

### CLI Arguments

| Flag | Description      | Values                    |
| ---- | ---------------- | ------------------------- |
| `-s` | Severity level   | `patch`, `minor`, `major` |
| `-i` | Increment amount | Number (default: 1)       |
| `-h` | Show help        | -                         |

**Examples:**

```bash
v-bump -s patch         # 1.0.0 → 1.0.1
v-bump -s patch -i 2    # 1.0.1 → 1.0.3
v-bump -s minor         # 1.4.9 → 1.5.0
v-bump -s major         # 1.2.5 → 2.0.0
v-bump -s major -i 2    # 1.2.5 → 3.0.0
```

### Git Commit Parsing

When no arguments are passed, v-bump reads the latest git commit message for version instructions.

**Format:** `[[severity:increment]]`

```bash
git commit -m "fix: resolve login bug [[patch:1]]"
v-bump  # 1.0.0 → 1.0.1

git commit -m "feat: add new API [[minor:1]]"
v-bump  # 1.0.1 → 1.1.0

git commit -m "breaking: restructure database [[major:1]]"
v-bump  # 1.1.0 → 2.0.0
```

## Version Reset Behavior

- **Major bump**: Resets minor and patch to 0
- **Minor bump**: Resets patch to 0
- **Patch bump**: Increments patch only

## License

MIT
