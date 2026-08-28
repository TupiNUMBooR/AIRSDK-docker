# AIR SDK Docker

![CI/CD](https://github.com/TupiNUMBooR/AIRSDK-docker/actions/workflows/ci-cd.yml/badge.svg)
![Latest Release](https://img.shields.io/github/release/TupiNUMBooR/AIRSDK-docker)
![Release Date](https://img.shields.io/github/release-date/TupiNUMBooR/AIRSDK-docker)

![Docker](https://img.shields.io/badge/docker-ghcr-blue?logo=docker)
![Windows Containers](https://img.shields.io/badge/containers-Windows-0078D6?logo=windows)

Windows Docker image with Harman AIR SDK for building ActionScript 3 applications for Windows and Android.

## Usage

Docker must run in Windows container mode.

```powershell
docker pull ghcr.io/tupinumboor/airsdk-docker:latest
```

Image check:

```powershell
docker run --rm --platform windows/amd64 `
	ghcr.io/tupinumboor/airsdk-docker:latest `
	adt.bat -version
```

Build a project from the current directory:

```powershell
docker run --rm --platform windows/amd64 `
	--volume "${PWD}:C:/workspace" `
	ghcr.io/tupinumboor/airsdk-docker:latest `
	compc.bat --help
```

Use `adt.bat` to package an application.
