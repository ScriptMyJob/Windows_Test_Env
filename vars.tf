########################################
### Variables ##########################
########################################

data "aws_availability_zones" "available" {}

variable "global" {
    type = "map"
    default = {
        environment = "td"
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
        image       = "ami-6a887b12"
        size        = "m3.medium"
        key_name    = "Windoze"
        sgs         = "sg-881718f5"
        subnet1     = "subnet-b378d3fa"
        bootstrap   =<<POWERSHELL_BOOTSTRAP
<powershell>
$Password = ConvertTo-SecureString "4NJmXTDPh7EuUVrFQVU3" -AsPlainText -Force
New-LocalUser "rjackson" -Password $Password
Add-LocalGroupMember -Group "Administrators" -Member "rjackson"

$url = 'https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1' 
$output = "C:\Windows\Temp\ConfigureRemotingForAnsible.ps1"

Invoke-WebRequest -Uri $url -OutFile $output

C:\Windows\Temp\ConfigureRemotingForAnsible.ps1 -CertValidityDays 100
</powershell>
POWERSHELL_BOOTSTRAP

        spot_price  = 0.07
        min_size    = 1
        max_size    = 1
        tag_name    = "Windows Testing Server"
    }
}
