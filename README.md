# dockerfiles

Container images built on GitHub-hosted runners and pushed to `ghcr.io/zocimek/<image>`.
The cluster pulls them through zot's sync mirror as `registry.pospiech.dev/<image>`.

| Image | Path | Purpose |
|---|---|---|
| `ghcr.io/zocimek/cezar` | [`cezar/`](cezar) | [cezar](https://github.com/open-mercato/cezar) cockpit with Claude Code, Codex and a mise-managed toolchain |

## cezar

Tools are pinned in [`cezar/mise.toml`](cezar/mise.toml) and installed system-wide. A repository's own
`mise.toml` takes precedence inside its checkout; missing versions are installed on first use into the
work volume.
