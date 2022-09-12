<# 
.COMPONENT
    YouTubeDL-Wonderful
.AUTHOR
    Robert Michael Smith <nightwintertooth@gmail.com>
.VERSION
    1.0.0a
.SYNOPSIS
    A module that performs the splendid process for YouTubeDL
.DESCRIPTION
    This module allows you to run YouTube-DL in an entirely portable environment.
    It defeats the purpose of the executable for customized versions of YouTube-DL
    allowing to be run from raw python code rather than the executable for your next
    web scraping project.  YouTube-DL's name is misleading.  It is a mass file downloader
    that is good for web scraping with an ffmpeg socket that allows unification of
    file formats.  The community has realized how valuable YouTube-DL is to webscraping for
    public domain uses such as AI training.

    This is that PS extension.
.NOTES
    The script contains extended archival features that the base YouTube-DL does not. 
    It ended up being a very useful tool for me over the years.  It is now yours in the
    public domain as a single repository.
#>
Param(
    [Parameter(Mandatory=$false)][Switch]$Music = $false,
    [Parameter(Mandatory=$false)][Switch]$Video = $false,
    [Parameter(Mandatory=$false)][Switch]$Clean = $false,
    [Parameter(Mandatory=$false)][Switch]$Install = $false,
    [Parameter(Mandatory=$false)][Switch]$Run = $false, 
    [Parameter(Mandatory=$false)][String]$youtubeDLPath,
    [Parameter(Mandatory=$false)][String]$ffmpegPath,
    [Parameter(Mandatory=$false)][String]$sevenZipPath,
    [Parameter(Mandatory=$false)][String]$pyEnvPath,
    [Parameter(Mandatory=$true)][String]$Url
)

$myPath = $MyInvocation.MyCommand.Path | Split-Path -Parent

<# Validate Command Line Arguments #>
if ($Music -eq $true -and $Video -eq $true) {
    Write-Error "E: Cannot specify both Music and Video flags in the same invocation."
    Exit 0
}
if (-not $youtubeDLPath) {
    $youtubeDLPath = "${myPath}\bin\youtube-dl"
    Write-Verbose "No YouTube DL path specified, it has defaulted to ${youtubeDLPath}"
}
if (-not $ffmpegPath) {
    $ffmpegPath = "${myPath}\bin\ffmpeg"
    Write-Verbose "No FFMpeg path specified, it has defaulted to ${ffmpegPath}"
}
if (-not $sevenZipPath) {
    $sevenZipPath = "${myPath}\bin\7zip"
    Write-Verbose "No 7-Zip path specified, it has defaulted to ${sevenZipPath}"
}
if (-not $pyEnvPath) {
    $pyEnvPath = "${myPath}\bin\pyenv"
    Write-Verbose "No PyEnv path specified, it has defaulted to ${pyEnvPath}"
}


<# PyEnv Envrionment controller submodule.  
   Taken from install-pyenv-win.ps1 in source code and redone. #>

function Enter-PyEnv() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$PyEnvPath,
        [Parameter(Position=1, Mandatory=$true)][String]$PyWinVersion
        )
    Write-Verbose "Taking backup of user's environment for handle."
    $pyEnvHandle = [hashtable]@{
        PyEnv = [System.Environment]::GetEnvironmentVariable('PYENV', "User")
        PyEnvRoot = [System.Environment]::GetEnvironmentVariable('PYENV_ROOT', "User")
        PyEnvHome = [System.Environment]::GetEnvironmentVariable('PYENV_HOME', "User")
        Path = [System.Environment]::GetEnvironmentVariable('PATH', "User")
    }
    Write-Verbose "Spawning PyEnv for python version ${PyWinVersion} in ${PyEnvPath}"
    [System.Environment]::SetEnvironmentVariable('PYENV', "${PyEnvPath}\pyenv-win\", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', "${PyEnvPath}\pyenv-win\", "User")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME', "${PyEnvPath}\pyenv-win\", "User")
    $PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"
    $NewPathParts = $PathParts.Where{ $_ -ne "${PyEnvPath}\pyenv-win\bin" }.Where{ $_ -ne "${PyEnvPath}\pyenv-win\shims" }
    $NewPathParts = ("${PyEnvPath}\pyenv-win\bin", "${PyEnvPath}\pyenv-win\shims") + $NewPathParts
    $NewPath = $NewPathParts -Join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")
    return $pyEnvHandle
}

function Exit-PyEnv() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][hashtable]$PyEnvHandle
        )
        Write-Verbose "Restoring user's environment after PyEnv operation."
        [System.Environment]::SetEnvironmentVariable('PYENV', $PyEnvHandle['PYENV'] , "User")
        [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', $PyEnvHandle['PYENV_ROOT'] , "User")
        [System.Environment]::SetEnvironmentVariable('PYENV_HOME', $PyEnvHandle['PYENV_HOME'] , "User")
        [System.Environment]::SetEnvironmentVariable('PATH', $PyEnvHandle['PATH'] , "User")
}

function Start-PyEnv() {
    . .\env\Scripts\activate.ps1
}

function Stop-PyEnv() {
    . deactivate
}

<# Dependency installation submodule #>

function Install-PyEnv() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$PyEnvPath,
        [Parameter(Position=1, Mandatory=$true)][String]$SevenZipPath,
        [Parameter(Position=2, Mandatory=$true)][String]$PyWinVersion 
        )
    New-Item -Path $PyEnvPath -ItemType Directory | Out-Null
    Push-Location -Path $PyEnvPath
    Invoke-WebRequest "https://github.com/pyenv-win/pyenv-win/archive/master.zip" -OutFile ".\pyenv-win.zip"
    Invoke-Expression "${SevenZipPath}\7za.exe x -y '${PyEnvPath}\pyenv-win.zip`' -o`'.\`'"
    Remove-Item "${PyEnvPath}\pyenv-win.zip" -Force
    Move-Item -Path "${PyEnvPath}\pyenv-win-master\*" -Destination $PyEnvPath -Force
    Remove-Item "${PyEnvPath}\pyenv-win-master" -Force
    Pop-Location
    $pyEnvHandle = Enter-PyEnv -PyEnvPath $PyEnvPath -PyWinVersion $PyWinVersion
    Invoke-Expression "pyenv install ${PyWinVersion}"
    Invoke-Expression "pyenv local ${PyWinVersion}"
    Exit-PyEnv -PyEnvHandle $pyEnvHandle
}

function Install-SevenZip() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$SevenZipPath
        )
    New-Item -Path $SevenZipPath -ItemType Directory | Out-Null
    Push-Location -Path $SevenZipPath
    Invoke-WebRequest "https://www.7-zip.org/a/7zr.exe" -OutFile ".\7zr.exe"
    $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://www.7-zip.org/download.html' | Select-Object -ExpandProperty Links | Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-extra.7z")} | Select-Object -First 1 | Select-Object -ExpandProperty href)
    $bundlePath = Join-Path $SevenZipPath (Split-Path $dlurl -Leaf)
    Invoke-WebRequest $dlurl -OutFile $bundlePath
    Invoke-Expression ".\7zr.exe e -y '${bundlePath}`' -o`'.\`'"
    Remove-Item "${bundlePath}" -Force
    Remove-Item "${SevenZipPath}\7zr.exe" -Force
    Pop-Location
}

function Install-FFMpeg() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$FFMpegPath,
        [Parameter(Position=0, Mandatory=$true)][String]$SevenZipPath
        )
    New-Item -Path $FFMpegPath -ItemType Directory | Out-Null
    Invoke-WebRequest "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z" -OutFile "${FFMpegPath}\ffmpeg-release-full.7z"
    Push-Location -Path $FFMpegPath
    Invoke-Expression "${SevenZipPath}\7za.exe e -y '${FFMpegPath}\ffmpeg-release-full.7z`' -o`'.\`'"
    Remove-Item -Path ".\ffmpeg-release-full.7z" -Force
    Get-ChildItem -Recurse -Path .\ -Filter *.exe | ForEach-Object {
        Move-Item $_ -Destination $FFMpegPath
    }
    Get-ChildItem -Recurse -Path .\ -Exclude *.exe | ForEach-Object {
        Remove-Item $_ -Force
    }
    Pop-Location 
}
function Install-YouTubeDL() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$YouTubeDLPath
        )
    New-Item -Path $YouTubeDLPath -ItemType Directory | Out-Null
    Push-Location -Path $YouTubeDLPath
    Invoke-Expression "git init"
    Invoke-Expression "git remote add -f origin 'https://github.com/ytdl-org/youtube-dl.git'"
    Invoke-Expression "git pull origin master"
    Remove-Item -Path $("{0}\.git\" -f $YouTubeDLPath) -Recurse -Force
    Pop-Location
}

function Configure-YouTubeDL() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$PyEnvPath,
        [Parameter(Position=1, Mandatory=$true)][String]$PyWinVersion 
        )
        $pyEnvHandle = Enter-PyEnv -PyEnvPath $PyEnvPath -PyWinVersion $PyWinVersion
        Invoke-Expression "python -m pip install --upgrade pip"
        Invoke-Expression "python -m pip install wheel"
        Exit-PyEnv -PyEnvHandle $pyEnvHandle
}

function Run-YouTubeDL() {
    Param(
        [Parameter(Position=0, Mandatory=$true)][String]$YouTubeDLPath,
        [Parameter(Position=1, Mandatory=$true)][String]$PyEnvPath,
        [Parameter(Position=2, Mandatory=$true)][String]$PyWinVersion    
        )
    $pyEnvHandle = Enter-PyEnv -PyEnvPath $PyEnvPath -PyWinVersion $PyWinVersion
    Push-Location $YoutubeDLPath
    $expression = $("python -m youtube_dl --config-location `"..\..\src\{0}{1}`" `'{2}`'" -f ($Music -eq $true ? "youtube-dl-music.conf" : ""), ($Video -eq $true ? "youtube-dl-video.conf" : ""), $Url)
    Invoke-Expression $expression
    Pop-Location
    Exit-PyEnv -PyEnvHandle $pyEnvHandle
}

<# Main #>

<# Perform cleanup #>
if ( $Clean -eq $true ) {
    @($youtubeDLPath, $ffmpegPath, $sevenZipPath, $pyEnvPath) | ForEach-Object {
        $item = $_
        if ( $(Test-Path -Path $item) ) {
            Write-Host ("Cleaning up old directory: {0}" -f $item)
            Remove-Item -Path $item -Recurse -Force
        }
    }
}

<# Perform installations #>
if ( $Install -eq $true ) {
    if ( -Not $(Test-Path -Path $sevenZipPath )) {
        Install-SevenZip -SevenZipPath $sevenZipPath
    }

    if ( -Not $(Test-Path -Path $ffmpegPath )) {
        Install-FFMpeg -FFMpegPath $ffmpegPath -SevenZipPath $sevenZipPath
    }

    if ( -Not $(Test-Path -Path $pyEnvPath )) {
        Install-PyEnv -PyEnvPath $pyEnvPath -SevenZipPath $sevenZipPath -PyWinVersion "3.10.7"
    }

    if ( -Not $(Test-Path -Path $youtubeDLPath )) {
        Install-YouTubeDL -YouTubeDLPath $youtubeDLPath
        Configure-YouTubeDL -PyEnvPath $pyEnvPath -PyWinVersion "3.10.7"
    }
}

if ( $Run -eq $true ) {
    Run-YouTubeDL -YouTubeDLPath $youtubeDLPath -PyEnvPath $pyEnvPath -PyWinVersion "3.10.7"
}
