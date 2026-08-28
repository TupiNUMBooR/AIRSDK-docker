FROM mcr.microsoft.com/windows/servercore:ltsc2022

ARG SDK_ARCHIVE
ARG SDK_VERSION

SHELL ["powershell", "-NoLogo", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV JAVA_HOME=C:/java AIR_SDK_HOME=C:/air-sdk AIR_HOME=C:/air-sdk ANDROID_SDK_ROOT=C:/android-sdk ANDROID_HOME=C:/android-sdk SDK_VERSION=${SDK_VERSION} PATH=C:/java/bin;C:/air-sdk/bin;C:/android-sdk/platform-tools;C:/android-sdk/cmdline-tools/latest/bin;${PATH}

RUN New-Item -ItemType Directory -Force C:/tools, C:/android-sdk, C:/java | Out-Null; Invoke-WebRequest -Uri https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse -OutFile C:/tools/jdk.zip; Expand-Archive C:/tools/jdk.zip C:/java; $jdkRoot = Get-ChildItem C:/java -Directory | Select-Object -First 1; if (-not $jdkRoot) { throw 'JDK installation failed' }; Copy-Item "$($jdkRoot.FullName)\*" C:/java -Recurse; Remove-Item -Recurse -Force $jdkRoot.FullName; Invoke-WebRequest -Uri https://www.7-zip.org/a/7z2408-x64.exe -OutFile C:/tools/7z.exe; Start-Process C:/tools/7z.exe -ArgumentList '/S' -Wait; Invoke-WebRequest -Uri https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip -OutFile C:/tools/android-tools.zip; Expand-Archive C:/tools/android-tools.zip C:/android-sdk/cmdline-tools; Rename-Item C:/android-sdk/cmdline-tools/cmdline-tools C:/android-sdk/cmdline-tools/latest; $env:JAVA_HOME = 'C:/java'; $env:Path = "C:/java/bin;$env:Path"; 1..20 | ForEach-Object { 'y' } | & C:/android-sdk/cmdline-tools/latest/bin/sdkmanager.bat --licenses; & C:/android-sdk/cmdline-tools/latest/bin/sdkmanager.bat --sdk_root=C:/android-sdk 'platform-tools' 'platforms;android-34' 'build-tools;34.0.0'; Remove-Item -Recurse -Force C:/tools

COPY ${SDK_ARCHIVE} C:/tmp/air-sdk.7z

RUN New-Item -ItemType Directory -Force C:/tmp/air-sdk-extracted, C:/air-sdk | Out-Null; & 'C:/Program Files/7-Zip/7z.exe' x -y C:/tmp/air-sdk.7z -oC:/tmp/air-sdk-extracted; $sdkRoot = Get-ChildItem C:/tmp/air-sdk-extracted -Directory | Select-Object -First 1; if ($sdkRoot) { Copy-Item "$($sdkRoot.FullName)\*" C:/air-sdk -Recurse } else { Copy-Item C:/tmp/air-sdk-extracted\* C:/air-sdk -Recurse }; Remove-Item -Recurse -Force C:/tmp

COPY Dockerfile compose.yml README.md C:/app/meta/

RUN if (-not (Test-Path C:/air-sdk/bin/compc.bat)) { throw 'Windows AIR SDK compc.bat is missing' }; if (-not (Test-Path C:/air-sdk/bin/adt.bat)) { throw 'Windows AIR SDK adt.bat is missing' }; New-Item -ItemType Directory -Force C:/tmp/airsdk-smoke/src/smoke, C:/tmp/airsdk-smoke/out | Out-Null; 'package smoke { public class Smoke { public function Smoke() {} } }' | Set-Content C:/tmp/airsdk-smoke/src/smoke/Smoke.as; & C:/air-sdk/bin/compc.bat -source-path C:/tmp/airsdk-smoke/src -include-sources C:/tmp/airsdk-smoke/src -output C:/tmp/airsdk-smoke/out/smoke.swc; if (-not (Test-Path C:/tmp/airsdk-smoke/out/smoke.swc)) { throw 'AIR SDK smoke compilation failed' }; & C:/air-sdk/bin/adt.bat -version; Remove-Item -Recurse -Force C:/tmp/airsdk-smoke

WORKDIR C:\workspace

CMD ["compc.bat"]
