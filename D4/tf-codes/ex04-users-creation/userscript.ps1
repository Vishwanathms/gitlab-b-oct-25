# Import PowerCLI
Import-Module VMware.PowerCLI -ErrorAction Stop
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connect to vCenter
Connect-VIServer -Server vcenter01.vishwacloudlab.in -User administrator@vsphere.local -Password 'VMware1!VMware1!'

# Create multiple users
$users = "harish","niranjan","amrutha","poovendan","ruban","asritha","yesaswini","sarika"

foreach ($u in $users) {
    New-SsoPersonUser -Domain "vsphere.local" `
                      -Name $u `
                      -Password (ConvertTo-SecureString "Passw0rd@123" -AsPlainText -Force) `
                      -GivenName $u `
                      -FamilyName "Admin" `
                      -EmailAddress "$u@example.com"

    # Assign Administrator role
    New-VIPermission -Entity (Get-Folder -Name "Datacenters") `
                     -Principal "vsphere.local\$u" `
                     -Role "Administrator" `
                     -Propagate $true
}

Disconnect-VIServer -Confirm:$false
