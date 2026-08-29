# AIR SDK Docker

![CI/CD](https://github.com/TupiNUMBooR/AIRSDK-docker/actions/workflows/ci-cd.yml/badge.svg)
![Latest Release](https://img.shields.io/github/release/TupiNUMBooR/AIRSDK-docker)
![Release Date](https://img.shields.io/github/release-date/TupiNUMBooR/AIRSDK-docker)

![Docker](https://img.shields.io/badge/docker-ghcr-blue?logo=docker)

Ubuntu Docker image with Harman AIR SDK for building ActionScript 3 applications and Android packages.

Every image build compiles a smoke-test SWC and SWF, then packages a signed captive-runtime APK.

## Usage

```bash
docker pull ghcr.io/tupinumboor/airsdk-docker:latest
```

Image check:

```bash
docker run --rm --platform linux/amd64 \
	ghcr.io/tupinumboor/airsdk-docker:latest \
	adt -version
```

Build a project from the current directory:

```bash
docker run --rm --platform linux/amd64 \
	--volume "$PWD:/workspace" \
	ghcr.io/tupinumboor/airsdk-docker:latest \
	compc -help
```

Use `adt` to package an Android APK or AAB.

The image targets `linux/amd64`. Windows executables must be packaged with the image from the `windows` branch.
