ARG SDK_ARCHIVE
ARG SDK_VERSION

FROM alpine:3.22 AS sdk-unpack

ARG SDK_ARCHIVE
ARG SDK_VERSION

RUN : "${SDK_ARCHIVE:?SDK_ARCHIVE build argument is required}" \
	&& : "${SDK_VERSION:?SDK_VERSION build argument is required}"

RUN apk add --no-cache 7zip

COPY ${SDK_ARCHIVE} /tmp/air-sdk.7z

RUN mkdir -p /tmp/air-sdk /opt/air-sdk \
	&& 7zz x -y /tmp/air-sdk.7z -o/tmp/air-sdk >/dev/null \
	&& adt_path="$(find /tmp/air-sdk -type f -path '*/bin/adt' -print -quit)" \
	&& test -n "${adt_path}" \
	&& sdk_root="$(dirname "$(dirname "${adt_path}")")" \
	&& cp -a "${sdk_root}/." /opt/air-sdk/ \
	&& find /opt/air-sdk/bin /opt/air-sdk/lib/android/bin -type f -exec chmod +x {} + \
	&& rm -rf /tmp/air-sdk /tmp/air-sdk.7z


FROM eclipse-temurin:17-jdk-jammy AS base

ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=11076708
ARG ANDROID_PLATFORM_VERSION=35
ARG ANDROID_BUILD_TOOLS_VERSION=35.0.0
ARG SDK_VERSION

ENV AIR_SDK_HOME=/opt/air-sdk \
	AIR_HOME=/opt/air-sdk \
	ANDROID_SDK_ROOT=/opt/android-sdk \
	ANDROID_HOME=/opt/android-sdk \
	AIR_ANDROID_SDK_HOME=/opt/android-sdk \
	SDK_VERSION=${SDK_VERSION} \
	PATH=/opt/air-sdk/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/cmdline-tools/latest/bin:${PATH}

COPY --from=sdk-unpack /opt/air-sdk/ /opt/air-sdk/

RUN apt-get update \
	&& apt-get install --yes --no-install-recommends wget \
	&& mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" \
	&& wget --quiet \
		"https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}_latest.zip" \
		-O /tmp/android-tools.zip \
	&& cd "${ANDROID_SDK_ROOT}/cmdline-tools" \
	&& jar xf /tmp/android-tools.zip \
	&& mv cmdline-tools latest \
	&& chmod +x latest/bin/* \
	&& rm /tmp/android-tools.zip \
	&& yes | sdkmanager --licenses >/dev/null \
	&& sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" \
		"platform-tools" \
		"platforms;android-${ANDROID_PLATFORM_VERSION}" \
		"build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
	&& ln -sf "${ANDROID_SDK_ROOT}/platform-tools/adb" /opt/air-sdk/lib/android/bin/adb \
	&& ln -sf "${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/aapt" /opt/air-sdk/lib/android/bin/aapt \
	&& ln -sf "${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/aapt2" /opt/air-sdk/lib/android/bin/aapt2 \
	&& apt-get purge --yes --auto-remove wget \
	&& rm -rf /var/lib/apt/lists/*


FROM base AS test

WORKDIR /tmp/airsdk-smoke

COPY test/ ./

RUN test -x /opt/air-sdk/bin/compc \
	&& test -x /opt/air-sdk/bin/mxmlc \
	&& test -x /opt/air-sdk/bin/adt \
	&& test -f /opt/air-sdk/lib/compc-cli.jar \
	&& adt_version="$(adt -version)" \
	&& printf '%s\n' "${adt_version}" \
	&& printf '%s' "${adt_version}" | grep -Fq "${SDK_VERSION}" \
	&& /opt/air-sdk/lib/android/bin/aapt version

RUN mkdir -p out \
	&& compc \
		-source-path . \
		-include-sources Smoke.as \
		-output out/smoke.swc \
	&& test -s out/smoke.swc

RUN mxmlc \
		-source-path . \
		-output out/Smoke.swf \
		Smoke.as \
	&& test -s out/Smoke.swf

RUN adt -certificate \
		-cn Smoke \
		2048-RSA \
		smoke.p12 \
		smoke-test \
	&& test -s smoke.p12

RUN if adt -package \
	-target apk-captive-runtime \
	-storetype pkcs12 \
	-keystore smoke.p12 \
	-storepass smoke-test \
	smoke.apk \
	Smoke-app.xml \
	-C out Smoke.swf \
	>package.log 2>&1; then \
		cat package.log; \
	else \
		tail -n 80 package.log; \
		exit 1; \
	fi \
	&& test -s smoke.apk \
	&& touch passed


FROM base AS runtime

COPY --from=test /tmp/airsdk-smoke/passed /usr/local/share/airsdk/smoke-tested
COPY Dockerfile compose.yml README.md /app/meta/

WORKDIR /workspace

CMD ["compc"]
