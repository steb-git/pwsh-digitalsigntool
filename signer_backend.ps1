# Debug implementation to solve pipelines not binding to the base argument, added flexibility to backend.
# ---- start of functions block ----
function filterCert {
    (
        Where-Object {$_.Subject -eq "CN=$certName"}
    )
}
# ---- end of functions block ----
Clear-Host
$certStdin = Read-Host "Who would you like to issue the Digital Certificate to?`n`n[ ISSUER_NAME ] >"
$certName = "$certStdin"
#$newcert = New-SelfSignedCertificate -Subject $certName -CertStoreLocation Cert:\LocalMachine\My -Type CodeSigningCert -KeyDescription "Self-signed digital signature certificate, generated using github.com/steb-git/pwsh-digicerttool." -Verbose
New-SelfSignedCertificate -Subject $certName -CertStoreLocation Cert:\LocalMachine\My -Type CodeSigningCert -KeyDescription 'Self-signed digital signature certificate, generated using github.com/steb-git/pwsh-digicerttool.' -Verbose
## skip TrustedPublisher, PublisherStore storage for debug, de-memory leak
# $rootStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","LocalMachine")

# $rootStore.Open("ReadWrite")

# $rootStore.Add($newcert)

# $rootStore.Close()

# $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("TrustedPublisher","LocalMachine")

# $publisherStore.Open("ReadWrite")

# $publisherStore.Add($newcert)

# $publisherStore.Close()

Get-ChildItem Cert:\LocalMachine\My | filterCert
# Get-ChildItem Cert:\LocalMachine\Root | filterCert ; Get-ChildItem Cert:\LocalMachine\TrustedPublisher | filterCert

Write-Host "-----------------------------------"
Write-Host
Write-Host "Digital signature certificate: " -NoNewline
Write-Host "($certName)" -ForegroundColor Yellow -NoNewline
Write-Host " successfully created!"

$codeCertificate = Get-ChildItem -Path 'Cert:\LocalMachine\My\' | filterCert
Set-AuthenticodeSignature -FilePath 'C:/Users/steb/dummy.ps1' -Certificate "$codeCertificate" -TimeStampServer http://timestamp.digicert.com
Get-ChildItem "Cert:\LocalMachine\My\$certName"
#$authenticode = New-SelfSignedCertificate -Subject "ATA Authenticode" -CertStoreLocation Cert:\LocalMachine\My -Type CodeSigningCert