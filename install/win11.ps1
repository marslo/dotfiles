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
[Net.WebRequest]::DefaultWebProxy.Credentials = [Net.CredentialCache]::DefaultCredentials
$env:chocolateyProxyLocation = 'http://proxy.sample.com:8080'
choco config set --name="'proxy'" --value="'http://proxy.sample.com:8080'"
choco config set --name="'proxyBypassOnLocal'" --value="'true'"
choco config list

Get-ExecutionPolicy
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

choco upgrade microsoft-windows-terminal
choco install -y python312
choco install -y make
choco install -y go
# C:\Users\marslo\AppData\Local\Temp\chocolatey\neovim\0.9.5\nvim-win64.zip
choco install -y neovim
choco install -y fzf
choco install -y ripgrep
choco install -y fd

# powershell models
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module PSReadLine
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

Install-Module PSWriteColor
Install-Module WebKitDev
Install-Module PowerShellGet -Force

# vim plugin
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/.vim/autoload/plug.vim -Force
cd "C:\Users\marslo\.vim\plugged\vim-hexokinase"
make hexokinase

# PowerToys Run
# copy `_def` to `C:\ProgramData\Microsoft\Windows\Start Menu\Programs`

npm install -g doctoc
