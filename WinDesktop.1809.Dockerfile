# escape=`

# Installer image
FROM mcr.microsoft.com/windows/servercore:1809 AS installer

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core Runtime
# USER ContainerAdministrator
RUN $dotnet_version = '3.1.5'; `
    Invoke-WebRequest -OutFile dotnet-installer.exe https://download.visualstudio.microsoft.com/download/pr/86835fe4-93b5-4f4e-a7ad-c0b0532e407b/f4f2b1239f1203a05b9952028d54fc13/windowsdesktop-runtime-3.1.5-win-x64.exe; `
    $dotnet_sha512 = '5df17bd9fed94727ec5b151e1684bf9cdc6bfd3075f615ab546759ffca0679d23a35fcf7a8961ac014dd5a4ff0d22ef5f7434a072e23122d5c0415fcd4198831'; `
    if ((Get-FileHash dotnet-installer.exe -Algorithm sha512).Hash -ne $dotnet_sha512) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    ./dotnet-installer.exe /S

# Runtime image 
FROM mcr.microsoft.com/windows/nanoserver:1809

ENV `
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true

# In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "%PATH%;C:\Program Files\dotnet"
USER ContainerUser

COPY --from=installer ["/Program Files/dotnet", "/Program Files/dotnet"]

# docker build -t tonysneed/dotnet-runtime-windowsdesktop:3.1-nanoserver-1809 -f WinDesktop.Dockerfile .