# hyper-v
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# wsl
wsl --set-default-version 2
wsl --install                                # Linux
wsl --install -d Ubuntu-22.04
wsl --install Ubuntu-22.04
wsl --set-default Ubuntu-22.04

# winget
Get-Command -Module Microsoft.WinGet.Client
Install-Module Microsoft.WinGet.Client
winget upgrade
winget show Microsoft.WindowsTerminal --versions

# choco
Get-ExecutionPolicy
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco upgrade microsoft-windows-terminal
choco install python312
choco install make
choco install go

# vim plugin
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/.vim/autoload/plug.vim -Force
cd "C:\Users\marslo\.vim\plugged\vim-hexokinase"
make hexokinase
