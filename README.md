# Сборщик AIR SDK

Windows Docker-образ с Harman AIR SDK для сборки ActionScript 3-приложений под Windows и Android.

## Настройки

Файл `.env` должен содержать версию и архив SDK:

```env
SDK_VERSION=51.3.4
SDK_ARCHIVE=AIRSDK_51.3.4.7z
```

Архив должен быть Windows-версией AIR SDK.

## Локальная сборка

Docker должен работать в режиме Windows containers. Запустите из корня проекта:

```bash
docker compose build
```

Compose автоматически загружает значения из `.env`, устанавливает Android SDK, распаковывает Windows AIR SDK и собирает образ `airsdk:${SDK_VERSION}`.

Контейнер содержит `compc` и `adt`, поэтому внутри него можно собирать:

- Windows native installer (`.exe`) через `adt -target native`;
- Android package (`.apk`) через `adt -target apk`;
- Android App Bundle (`.aab`) через `adt -target aab`.

Для Android и Windows нужны соответствующие сертификаты подписи. Не добавляйте keystore в образ.

## CI/CD

При каждом `push` workflow собирает и отправляет образ в Gitea. Для workflow требуется секрет `REPO_TOKEN` со следующими разрешениями:

- `read:repository` — checkout репозитория и скачивание архива;
- `write:package` — публикация Docker-образа и привязка контейнерного пакета к репозиторию.

SDK проприетарный, поэтому репозиторий и контейнерный пакет должны оставаться приватными.
