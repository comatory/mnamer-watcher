# mnamer-watcher

Watches a directory for new/moved media files using `inotifywait` and automatically organizes them with [mnamer](https://github.com/jkwill87/mnamer).

> **Linux only**: relies on `inotify` which requires a native Linux kernel. Bind-mounted volumes from macOS/Windows hosts do not propagate filesystem events to the container.

## Use

`docker pull comatory/mnamer-watcher:latest`

## Build

```bash
docker build -t mnamer-watcher .
```

## Run

```bash
docker run -d \
  --name mnamer-watcher \
  --volume /path/to/downloads:/mnt/watch \
  --volume /path/to/config:/mnt/.config \
  --volume /path/to/movies:/mnt/movies \
  --volume /path/to/tv:/mnt/tv \
  mnamer-watcher
```

## Volumes

| Container path | Required | Description |
|---|---|---|
| `/mnt/watch` | yes | Directory watched recursively for new/moved files |
| `/mnt/.config` | yes | mnamer config directory (must contain `.mnamer-v2.json`) |
| `/mnt/movies` | no | Movie output directory (must match `movie_directory` in config) |
| `/mnt/tv` | no | TV output directory (must match `episode_directory` in config) |

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `MNAMER_CONFIG` | `/mnt/.config/.mnamer-v2.json` | Path to mnamer config file |
| `EXCLUDE_PATTERN` | `/incomplete/` | Regex pattern for inotifywait `--exclude`, set empty to disable |

## mnamer config

All mnamer behavior is controlled via config file, no flags are passed beyond `--batch` and `--config-path`. The config file must be named `.mnamer-v2.json`. The `movie_directory` and `episode_directory` paths in the config must match the container mount points (e.g. `/mnt/movies`, `/mnt/tv`).

See [mnamer settings docs](https://github.com/jkwill87/mnamer/wiki/Settings) for all available options.
