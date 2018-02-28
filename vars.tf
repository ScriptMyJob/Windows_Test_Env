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
</powershell>
POWERSHELL_BOOTSTRAP

        spot_price  = 0.07
        min_size    = 1
        max_size    = 1
        tag_name    = "Windows Testing Server"
    }
}
