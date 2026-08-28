# AIR SDK Docker

![CI/CD](https://github.com/TupiNUMBooR/AIRSDK-docker/actions/workflows/ci-cd.yml/badge.svg)
![Latest Release](https://img.shields.io/github/release/TupiNUMBooR/AIRSDK-docker)
![Release Date](https://img.shields.io/github/release-date/TupiNUMBooR/AIRSDK-docker)

![Docker](https://img.shields.io/badge/docker-ghcr-blue?logo=docker)
![Windows Containers](https://img.shields.io/badge/containers-Windows-0078D6?logo=windows)

Windows Docker-образ с Harman AIR SDK для сборки ActionScript 3-приложений под Windows и Android.

## Usage

Docker должен работать в режиме Windows containers.

```powershell
docker pull ghcr.io/tupinumboor/airsdk-docker:latest
```

Проверка образа:

```powershell
docker run --rm --platform windows/amd64 `
	ghcr.io/tupinumboor/airsdk:latest `
	adt.bat -version
```

Сборка проекта из текущей директории:

```powershell
docker run --rm --platform windows/amd64 `
	--volume "${PWD}:C:/workspace" `
	ghcr.io/tupinumboor/airsdk:latest `
	compc.bat --help
```

Для упаковки приложения используйте `adt.bat`.
