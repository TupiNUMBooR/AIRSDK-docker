FROM alpine:3.22 AS sdk-unpack

ARG SDK_ARCHIVE

RUN apk add --no-cache 7zip

COPY ${SDK_ARCHIVE} /tmp/air-sdk.7z

# Find bin/adt instead of assuming whether the archive has a top-level folder.
RUN mkdir -p /tmp/air-sdk /opt/air-sdk \
	&& 7zz x -y /tmp/air-sdk.7z -o/tmp/air-sdk >/dev/null \
	&& adt_path="$(find /tmp/air-sdk -type f -path '*/bin/adt' -print -quit)" \
	&& test -n "${adt_path}" \
	&& sdk_root="$(dirname "$(dirname "${adt_path}")")" \
	&& cp -a "${sdk_root}/." /opt/air-sdk/ \
	&& find /opt/air-sdk/bin /opt/air-sdk/lib/android/bin -type f -exec chmod +x {} + \
	&& rm -rf /tmp/air-sdk /tmp/air-sdk.7z

FROM eclipse-temurin:17-jdk-jammy AS android-sdk

ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=11076708

ENV ANDROID_SDK_ROOT=/opt/android-sdk \
	ANDROID_HOME=/opt/android-sdk \
	PATH=/opt/android-sdk/cmdline-tools/latest/bin:${PATH}

RUN apt-get update \
	&& apt-get install --yes --no-install-recommends unzip wget \
	&& mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" \
	&& wget --quiet \
		"https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}_latest.zip" \
		-O /tmp/android-tools.zip \
	&& unzip -q /tmp/android-tools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools" \
	&& mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest" \
	&& rm /tmp/android-tools.zip \
	&& yes | sdkmanager --licenses >/dev/null \
	&& sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" \
		"platform-tools" \
		"platforms;android-34" \
		"build-tools;34.0.0"

FROM eclipse-temurin:17-jdk-jammy

ARG SDK_VERSION

ENV AIR_SDK_HOME=/opt/air-sdk \
	AIR_HOME=/opt/air-sdk \
	ANDROID_SDK_ROOT=/opt/android-sdk \
	ANDROID_HOME=/opt/android-sdk \
	SDK_VERSION=${SDK_VERSION} \
	PATH=/opt/air-sdk/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:${PATH}

COPY --from=sdk-unpack /opt/air-sdk/ /opt/air-sdk/
COPY --from=android-sdk /opt/android-sdk/ /opt/android-sdk/
COPY Dockerfile compose.yml README.md /app/meta/

# Verify packaging and compilation before the image can be published.
RUN test -x /opt/air-sdk/bin/compc \
	&& test -f /opt/air-sdk/lib/compc-cli.jar \
	&& test -x /opt/air-sdk/bin/adt \
	&& mkdir -p /tmp/airsdk-smoke/src/smoke /tmp/airsdk-smoke/out \
	&& printf '%s\n' \
		'package smoke { public class Smoke { public function Smoke() {} } }' \
		> /tmp/airsdk-smoke/src/smoke/Smoke.as \
	&& compc \
		-source-path /tmp/airsdk-smoke/src \
		-include-sources /tmp/airsdk-smoke/src \
		-output /tmp/airsdk-smoke/out/smoke.swc \
	&& test -s /tmp/airsdk-smoke/out/smoke.swc \
	&& adt -version \
	&& rm -rf /tmp/airsdk-smoke

WORKDIR /workspace

CMD ["compc"]
