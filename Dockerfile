FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London
#ENV WINEDEBUG=-all
ENV WINEPREFIX=/opt/msvc/pfx

RUN mkdir -p "$WINEPREFIX"
RUN chmod -R 777 "/opt/msvc"

RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get install -y wget

RUN wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN wget -nc -P /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources

RUN apt-get update && \
    apt-get install -y winehq-staging python msitools python-simplejson \
                       python-six ca-certificates winbind winetricks weston xinit libgl1-mesa-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN wine64 wineboot --init && \
    while pgrep wineserver > /dev/null; do sleep 1; done

RUN winetricks -f -q dotnet472

WORKDIR /msvc-temp
RUN wget https://aka.ms/vs/17/release/vs_buildtools.exe

RUN wget https://aka.ms/vs/17/release/installer
RUN mv installer installer.zip
RUN mkdir -p "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer"
RUN unzip installer.zip "Contents/*" -d "$WINEPREFIX/drive_c/Program Files (x86)/Microsoft Visual Studio/Installer"

RUN mkdir -p /tmp/.X11-unix

RUN XDG_RUNTIME_DIR="$HOME" weston --use-pixman --backend=headless-backend.so --xwayland & \
    DISPLAY=:0 wine vs_buildtools --wait --quiet --includeRecommended --includeOptional --add Microsoft.VisualStudio.Component.Windows11SDK.22000 --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools || true

RUN wget https://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/DXSDK_Jun10.exe
RUN XDG_RUNTIME_DIR="$HOME" weston --use-pixman --backend=headless-backend.so --xwayland & \
    DISPLAY=:1 wine DXSDK_Jun10.exe /S /O /U

# Ensure Win11 SDK is installed because sometimes vs buildtools just decide not to lol
RUN wget https://download.microsoft.com/download/f/6/7/f673df4b-4df9-4e1c-b6ce-2e6b4236c802/windowssdk/winsdksetup.exe
RUN XDG_RUNTIME_DIR="$HOME" weston --use-pixman --backend=headless-backend.so --xwayland & \
    DISPLAY=:2 wine winsdksetup.exe /features + /quiet /norestart

RUN rm -rf /msvc-temp
WORKDIR /
