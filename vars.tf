########################################
### Variables ##########################
########################################

data "aws_availability_zones" "available" {}

variable "global" {
    type = "map"
    default = {
        environment = "Development"
        region      = "us-west-2"
    }
}

variable "vpc" {
    type = "map"
    default = {
        var         = true
    }
}

variable "ec2" {
    type = "map"
    default = {
        lc_name     = "Windows Testing Server"
        asg_name    = "Windows Testing ASG"
        image       = "ami-f6d8008e"
        size        = "m3.medium"
        key_name    = "Windoze"
        sgs         = "sg-c05905bc"
        subnet1     = "subnet-af7977f4"
        bootstrap   =<<POWERSHELL_BOOTSTRAP
<powershell>
# User Configs
$Password = ConvertTo-SecureString "4NJmXTDPh7EuUVrFQVU3" -AsPlainText -Force
New-LocalUser "rjackson" -Password $Password
Add-LocalGroupMember -Group "Administrators" -Member "rjackson"

# Ansible
$url = 'https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'
$output = "C:\Windows\Temp\ConfigureRemotingForAnsible.ps1"
Invoke-WebRequest -Uri $url -OutFile $output

C:\Windows\Temp\ConfigureRemotingForAnsible.ps1 -CertValidityDays 100


# Choco
Set-ExecutionPolicy Bypass -Scope Process -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# vim
choco install vim -y
write-output "set swapfile`nset dir=C:\Temp" |
    Out-File -FilePath "$HOME\.vimrc"

$PROFILE = 'C:\Users\rjackson\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

if (Test-Path $PROFILE) {
    Write-Output "Set-Alias ll gci" |
        Out-File -FilePath "$PROFILE" -Append
} else {
    mkdir (Split-Path -Path "$PROFILE") -ErrorAction SilentlyContinue

    Write-Output "Set-Alias ll gci" |
        Out-File -FilePath "$PROFILE"
}

function Get-GoogleChrome {
    if ( -Not (Test-Path C:\temp\)) {
        mkdir 'C:\temp\'
    }

    (new-object System.Net.WebClient).DownloadFile(
        'http://dl.google.com/chrome/install/375.126/chrome_installer.exe',
        'C:\temp\chrome.exe'
    );
}

function Run-GoogleChromeInstaller {
    $job = Start-Job {
        C:\temp\chrome.exe /silent /install;
    };
    Wait-Job $job;
}

function Remove-GoogleChromeInstaller {
    Write-Host "Installing Google Chrome"
    do {
        Start-Sleep 1;
        Write-Host "." -NoNewline
        Remove-Item C:\temp\chrome.exe -Force -ErrorAction SilentlyContinue;
    } while ( Test-Path C:\temp\chrome.exe )
}

function Install-GoogleChrome {
    Get-GoogleChrome;
    Run-GoogleChromeInstaller;
    Remove-GoogleChromeInstaller;
    Get-Package -Name 'Google Chrome'
}

Install-GoogleChrome
</powershell>
POWERSHELL_BOOTSTRAP

        spot_price  = 0.07
        min_size    = 1
        max_size    = 1
        tag_name    = "Windows Testing Server"
    }
}
