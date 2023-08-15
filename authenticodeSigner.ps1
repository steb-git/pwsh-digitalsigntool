$validAnswer = $false
$Folder = '~/'
#$Folder = '~/test' #for debug purposes

# ----------------------[External functions area]------
function Is-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $item = Get-Item $Path

    return $item.PSIsContainer -eq $false
}
function Is-RunningAsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    return $isAdmin
}
function exit {
    Clear-Host
    exit
}
# ----------------------[functions end]----------------
$path = $signCandidate
$host.UI.RawUI.BackgroundColor = "Black"
Clear-Host
# This script requires to be executed with Administrator privileges to be able to import certain digital certificates from the TRG storage
# It will not run if it is not running as Admin.
if (Is-RunningAsAdmin) {}
    else {
        Write-Host "PowerShell Script Digital Signature Tool"
        Write-Host "─────────────────────────────────────────"
        Write-Host 
        Write-Host "    ┌────┐" -ForegroundColor Red
        Write-Host "    │ ╲╱ │" -ForegroundColor Red -NoNewline
        Write-Host "  This script requires Administrator privileges to digitally sign files properly." -ForegroundColor Yellow
        Write-Host "    │ ╱╲ │" -ForegroundColor Red -NoNewline
        Write-Host "  Please re-run this tool on an elevated console."
        Write-Host "    └────┘" -ForegroundColor Red
        Start-Sleep -Seconds 0.50
        Write-Host
        Write-Host "┌────────────────────────┐"
        Write-Host '│ Press any key to exit. │'
        Write-Host "└────────────────────────┘"
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        exit
    }
While(-not $validAnswer) {
    # Option select frontend
    $yn = Read-Host "PowerShell Script Digital Signature Tool`n─────────────────────────────────────────`n`nPlease select an option:`n`n[ 1 ] - Sign Powershell script`n[ 2 ] - Create or Manage self-signed certificates`n[ 3 ] - Close and return to Windows.`n`n>"
    Switch($yn.ToLower())
    {
        # Signer Tree
        "1" {$validAnswer = $true
            Clear-Host
            Write-Host "PowerShell Script Digital Signature Tool > Sign Powershell script"
            Write-Host "─────────────────────────────────────────"
            Start-Sleep -Seconds 0.25
            Write-Host
            $signCandidate = Read-Host "Please provide the path of the script to be signed:`nNOTE: Path must start with its corresponding volume label (eg: C:/myfolder/testscript.ps1)`n`nPath: >"
            Write-Host 
            Write-Host "Please wait while we verify the path..."
            Start-Sleep -Seconds 0.75
            # verification stage
        if (Test-Path -Path $signCandidate) {
            # Initiates signing when path is verified as valid + exists
            
            if (Get-ChildItem -path $signCandidate) {}
            else {
               
            }
            # Checks if given path is a file, an else statement would throw otherwise if it is a directory.
            if (Is-File $signCandidate){}
            else{
                Write-Host "Oops, that wasn't a file." -ForegroundColor Red
                Write-Host "Make sure to provide the path for a file, not a directory."
                Start-Sleep -Seconds 0.50
                Write-Host
                Write-Host "┌────────────────────────┐"
                Write-Host '│ Press any key to exit. │'
                Write-Host "└────────────────────────┘"
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                exit
            }
            # Checks if given path is a valid powershell source script, an else statement would throw otherwise if it does not satisfy the given statements.
            if ((Get-ChildItem -Path $signCandidate -force | Where-Object {$_.Extension -in '.ps1','.psm1','.psd1','.pssc','.psrc','.p1xml'}).Count -gt 0){
            # de facto regex exp is ('\.ps?1?m1?d1?sc?rc?1xml) 
                    Write-Host "Verified as a valid Powershell file." -ForegroundColor Green
            }
            else {
                Write-Host
                Write-Host "    ┌────┐" -ForegroundColor Yellow
                Write-Host "    │ ┌┐ │" -ForegroundColor Yellow -NoNewline
                Write-Host "  Oops, that didn't sound like a valid Powershell script." -ForegroundColor Red
                Write-Host "    │ └┘ │" -ForegroundColor Yellow -NoNewline
                Write-Host "  The tool only supports extensions ending with *.ps1, *.psm1, *.psd1, *.pssc, *.psrc and *.p1xml."
                Write-Host "    └────┘" -ForegroundColor Yellow
                Start-Sleep -Seconds 0.50
                Write-Host
                Start-Sleep -Seconds 0.50
                Write-Host
                Write-Host "┌────────────────────────┐"
                Write-Host '│ Press any key to exit. │'
                Write-Host "└────────────────────────┘"
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                exit
             },
            $filename = Get-ChildItem $signCandidate -Name
            Write-Host
            Start-Sleep -Seconds 0.70
            $signWithValid = read-host "File found! [$filename]`n`n----------[Note]-----------`n`nYou are about to sign this Powershell script with a digital signature, this allows other computers to trust this file thus verifies its legitimacy.`nMake sure this script is tested functional, otherwise there would be difficulties in executing this file after the signing process.`n`nWould you like to digitally sign this script?`n`n[ 1 ] - Yes`n[ 2 ] - No, Abort and close terminal.`n`n>"
            Write-Host
            # option that signs the script, very crucial.
            if ($signWithValid -eq 1){
                Clear-Host
                 Write-Host "PowerShell Script Digital Signature Tool > Sign Powershell script > Signing script..."
                 Write-Host "─────────────────────────────────────────"
                 Write-Host
                 Start-Sleep -Seconds 1
                 Write-Host "Preparing digital certificate for digital signing..."
                 $codeCertificate = Get-ChildItem -Path 'Cert:\LocalMachine\My\'| Where-Object { $_.Subject -eq 'CN=ATA Authenticode'}
                 Write-Host "Found digital certiificate! Digitally signing $filename (ATA Authenticode)..." -ForegroundColor Green
                 Start-Sleep -Seconds 1
                 Set-AuthenticodeSignature -FilePath $signCandidate -Certificate $codeCertificate -TimeStampServer 'http://timestamp.digicert.com' -verbose
                 Write-Host "$filename successfully signed!" -ForegroundColor Green
                 Write-Host
                 Write-Host "Verifying signature data..."
                 Start-Sleep -Seconds 0.75
                 Get-AuthenticodeSignature -FilePath $signCandidate | Select-Object -Property *
                 Write-Host "─────────────────────────────────────────-"
                 Write-Host
                 Write-Host "    ┌─────┐" -ForegroundColor Green
                 Write-Host "    │   ╱ │" -ForegroundColor Green -NoNewline
                 Write-Host "   PowerShell script has been digitally signed successfully!" -ForegroundColor Green
                 Write-Host "    │ ╲╱  │" -ForegroundColor Green -NoNewline
                 Write-Host "   Note that tampering the script's contents would invalidate the signature inside."
                 Write-Host "    └─────┘" -ForegroundColor Green
                 Write-Host
                 Write-Host "Should this happen again would require you to re-sign the script again to match the hash."
                 Start-Sleep -Seconds 0.50
                 Write-Host "┌────────────────────────┐"
                 Write-Host '│ Press any key to exit. │'
                 Write-Host "└────────────────────────┘"
                 $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                 exit
                }
         else{

            }
            

            if ($signWithValid -eq 2){
                Write-Host
                Write-Host 'Signing process aborted.'
                Start-Sleep -Seconds 0.50
                Write-Host
                Write-Host "┌────────────────────────┐"
                Write-Host '│ Press any key to exit. │'
                Write-Host "└────────────────────────┘"
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                exit
            }else{
                # -intentionally left blank
            }
            
        } 
        # If there is no previous version of SDVP present, an else statement will trigger instead.
    else {
    	# Checks if given path exists, an else statement would throw otherwise if it is an empty path, terminating the process.
            Write-Host
            Write-Host "    ┌────┐" -ForegroundColor Yellow
            Write-Host "    │ ┌┐ │" -ForegroundColor Yellow -NoNewline
            Write-Host "  Oops, that wasn't a file, or it was just empty." -ForegroundColor Red
            Write-Host "    │ └┘ │" -ForegroundColor Yellow -NoNewline
            Write-Host "  Make sure to provide the path for an existing file."
            Write-Host "    └────┘" -ForegroundColor Yellow
            Start-Sleep -Seconds 0.50
            Write-Host 
            Write-Host
            Write-Host "┌────────────────────────┐"
            Write-Host '│ Press any key to exit. │'
            Write-Host "└────────────────────────┘"
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
            }
    }
            # Dev Option tree
        "2" {$validAnswer = $true
          
        if (Test-Path -Path $Folder) {
            # Installation check gate for stable
            $updateDev = read-host "An existing installation of SDVP was found on your shaderpacks directory. Would you like to update it or perform a clean install instead?`n`n1 - Update SDVP (Backs up shader configs)`n2 - Reinstall SDVP (Removes EVERYTHING from the SDVP folder, giving it a fresh install)`n3 - Cancel Installation and return to Windows`n`n>"

            # If a recent installation was found, installer will trigger another read-host switch for dev
            # If user decides to update using dev:
            if ($updateDev -eq 1){
                Write-Host 'Press any key to exit.'
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                 exit
             }else{
             # -intentionally left blank
            }
            # If user decides to clean install using dev:
            if ($updateDev -eq 2){
                Write-Host 'Press any key to exit.'
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                exit
            }else{
            # -intentionally left blank
            }
            # Aborts installation until i learn how to do backward swtches, so this stays as a workaround.
            if ($updateDev -eq 3){
                Write-Host 'Installation was aborted.'
                Write-Host
                Write-Host 'Press any key to exit.'
                $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
                 exit
            }else{
            # -intentionally left blank
            }
        } 
    else {
        # If there is no previous version of SDVP present, an else statement will trigger instead for dev
	
        Write-Host 'Press any key to exit.'
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        exit}
    }
            #Abort
        "3" {$validAnswer = $true
            Write-Host 'Installation was aborted.'
            Start-Sleep -Seconds 0.50
            Write-Host
            Write-Host "┌────────────────────────┐"
            Write-Host '│ Press any key to exit. │'
            Write-Host "└────────────────────────┘"
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            exit
        Default {
        	Clear-Host
		Write-Host "That wasn't quite right, maybe give it another shot?"}
    }
}
}