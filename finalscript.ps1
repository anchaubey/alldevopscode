# Source URL
$CHROMEURL = ""
$GITULR = ""
$ECLIPSEURL = ""
$MAVENURL = ""
$JDKURL = ""
$ECLIPSE = ""
$INFURL = ""

$DOWNLOADDIR="C:\Softwares"
# Destation file

$username = 'admin'
$password = 'redhat'

$secPassword = ConvertTo-SecureString $password -AsPlainText -Force

$credObject = New-Object System.Management.Automation.PSCredential ($username, $secPassword)




# Download the file
Invoke-WebRequest -Uri $url -OutFile $dest -Credential $credObject


Set-ExecutionPolicy RemoteSigned -scope Process -Force

function cleanDirectory { Param($folder) 
    Write-Host "*********** Clean directory : ${folder} ***********"
    try {
    if ($folder -ne "" -And $folder -ne $null){
        Remove-Item -Path ${folder}/* -Recurse
    }
    }catch
    {
        Write-Error -Message "Unable to clean directory '$folder'. Error was: $_" -ErrorAction Stop
    }
}


function createDirectory { Param($folder) 
	Write-Host "*********** Create folder "${folder}"***********"
	try {
		New-Item ${folder} -itemType Directory
	}catch
	{
		Write-Error -Message "Unable to create directory '$folder'. Error was: $_" -ErrorAction Stop
	}
}

If (-not (Test-Path "${DOWNLOADDIR}")){
	createDirectory(${DOWNLOADDIR})
}else {
	cleanDirectory(${DOWNLOADDIR})
}


Write-Host "***********Starting Binary Dodwnload***********"
start-sleep 5

Write-Host "*********** Start Donwloading "CHROME BINARY" ***********"
try {	
    Invoke-WebRequest -Uri $CHROMEURL -OutFile $DOWNLOADDIR\ChromeSetup.exe -Credential $credObject -TimeoutSec 20800
}catch
{
    Write-Error -Message "Unable to download binary CHROME BINARY. Error was: $_" -ErrorAction Stop
}

Write-Host "*********** Start Donwloading "JDK BINARY" ***********"
try {	
    Invoke-WebRequest -Uri $JDKURL -OutFile $DOWNLOADDIR\JDK.exe -Credential $credObject -TimeoutSec 20800
}catch
{
    Write-Error -Message "Unable to download binary JDK BINARY. Error was: $_" -ErrorAction Stop
}

Write-Host "*********** Start Donwloading "MAVEN BINARY" ***********"
try {	
    Invoke-WebRequest -Uri $CHROMEURL -OutFile "$DOWNLOADDIR\apache-maven-3.8.1\maven.zip" -Credential $credObject -TimeoutSec 20800
}catch
{
    Write-Error -Message "Unable to download binary MAVEN BINARY. Error was: $_" -ErrorAction Stop
}

Write-Host "*********** Start Donwloading "GIT BINARY" ***********"
try {	
    Invoke-WebRequest -Uri $$GITULR -OutFile $DOWNLOADDIR\GIT.exe -Credential $credObject -TimeoutSec 20800
}catch
{
    Write-Error -Message "Unable to download binary GIT BINARY. Error was: $_" -ErrorAction Stop
}

Write-Host "*********** Start Donwloading "ECLIPSE BINARY" ***********"
try {	
    Invoke-WebRequest -Uri $ECLIPSE -OutFile $DOWNLOADDIR\ECLIPSE.exe -Credential $credObject -TimeoutSec 20800
}catch
{
    Write-Error -Message "Unable to download binary ECLIPSE BINARY. Error was: $_" -ErrorAction Stop
}

Write-Host "*********** Start Donwloading "INF FILE" ***********"
try {	
    Invoke-WebRequest -Uri $INFURL -OutFile $DOWNLOADDIR\installer.inf -Credential $credObject -TimeoutSec 20800
}catch
{
    Write-Error -Message "Unable to download binary ECLIPSE BINARY. Error was: $_" -ErrorAction Stop
}

installer.inf

Write-Host "Installing Apache Maven...." -ForegroundColor Cyan

$apachePath = "${DOWNLOADDIR}\Apache"
$mavenPath = "$apachePath\Maven"

if(Test-Path $mavenPath) {
    Remove-Item $mavenPath -Recurse -Force
}

if(-not (Test-Path $apachePath)) {
    New-Item $apachePath -ItemType directory -Force
}

Write-Host "Unpacking..."
Expand-Archive -LiteralPath $DOWNLOADDIR\apache-maven-3.8.1\maven.zip -DestinationPath $mavenPath

[Environment]::SetEnvironmentVariable("M2_HOME", $mavenPath, "Machine")
[Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "Machine")


Write-Host "Installing Git..........."

$installer = ${DOWNLOADDIR}\GIT.exe
$git_install_inf = "${DOWNLOADDIR}\installer.inf"
$install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""

try {	
    Start-Process -FilePath $installer -ArgumentList $install_args -Wait
}catch
{
    Write-Error -Message "Unable to download Install GIT. Error was: $_" -ErrorAction Stop
}

