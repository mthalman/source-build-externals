#!/bin/bash
set -euo pipefail

scriptroot=$(cd -P "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

installDir="$scriptroot/../.pwsh"
if [ ! -d $installDir ]; then
    powerShellVersion=$(curl -s "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

    # Get the architecture
    cpuname=$(uname -m)
    case $cpuname in
    arm64|aarch64)
        arch=arm64
        ;;
    amd64|x86_64)
        arch=x64
        ;;
    armv*l)
        arch=arm32
        ;;
    *)
        echo "Unsupported CPU $cpuname detected.">&2
        exit 1
        ;;
    esac

    osSuffix=""
    if cat /etc/os-release | grep -q "ID=alpine"; then
        osSuffix="-alpine"
    fi

    url="https://github.com/PowerShell/PowerShell/releases/download/v$powerShellVersion/powershell-$powerShellVersion-linux$osSuffix-$arch.tar.gz"
    tarballPath="$installDir/powershell.tar.gz"

    mkdir -p $installDir
    curl -L $url --output $tarballPath
    tar zxf $tarballPath -C $installDir
    rm $tarballPath
fi
