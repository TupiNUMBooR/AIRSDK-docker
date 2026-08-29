# AIR SDK Docker

![CI/CD](https://github.com/TupiNUMBooR/AIRSDK-docker/actions/workflows/ci-cd.yml/badge.svg)
![Latest Release](https://img.shields.io/github/release/TupiNUMBooR/AIRSDK-docker)
![Release Date](https://img.shields.io/github/release-date/TupiNUMBooR/AIRSDK-docker)

![Docker](https://img.shields.io/badge/docker-ghcr-blue?logo=docker)
[![AIR SDK](https://img.shields.io/badge/AIR%20SDK-51.3.3.2-blue)](https://airsdk.harman.com/)

Ubuntu Docker image with Harman AIR SDK for building ActionScript 3 applications and Android packages.

## Usage

Pull the image:

```bash
docker pull ghcr.io/tupinumboor/airsdk-docker:latest
```

or build it locally:

```bash
docker compose build
```

Check the AIR SDK version:

```bash
docker run --rm \
    ghcr.io/tupinumboor/airsdk-docker:latest \
    adt -version
```

Build an SWC from the current directory:

```bash
docker run --rm \
    --volume "$PWD:/workspace" \
    ghcr.io/tupinumboor/airsdk-docker:latest \
    compc ...
```

Build an SWF:

```bash
docker run --rm \
    --volume "$PWD:/workspace" \
    ghcr.io/tupinumboor/airsdk-docker:latest \
    mxmlc ...
```

Package an APK or AAB:

```bash
docker run --rm \
    --volume "$PWD:/workspace" \
    ghcr.io/tupinumboor/airsdk-docker:latest \
    adt -package ...
```
