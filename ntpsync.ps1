# Powershell-Script for syncing time with NTP Server
# Script owned by Apfelwerk GmbH & Co.KG
# Written by Benjamin Kollmer
# Copyright 22.08.2022

#Requires -RunAsAdministrator

# NTP Server to get actual timing
$NTPServer = "de.pool.ntp.org"

# Get Time from API and for setting as local time further in this script
$timeResponse = Invoke-WebRequest -Uri http://worldtimeapi.org/api/timezone/Europe/Berlin -UseBasicParsing

# Path to set time automatically
$autoTimePath = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters' 

# Registry Values
$on = 'NTP'
$off = 'NoSync'

# Get OS Info and don't set time to auto when on DC
# 2 equals for Domain-Controller
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem

if (($osInfo.ProductType)-ne 2){
        # Check if set time automatically setting is enabled
        if  ((Get-ItemPropertyValue -Path $autoTimePath -Name Type) -eq $off) {  
            Write-Host "### Warning: Set time automatically is not enabled. Enabling now..." -ForegroundColor Yellow
            Set-ItemProperty -Path $autoTimePath -Name 'Type' -Value $on
           
            if ((Get-ItemPropertyValue -Path $autoTimePath -Name Type) -eq $on){
                Write-Host "### Time has be set to automatically successfully!" -ForegroundColor Green
            }else{
                Write-Host "### Error: Something weird happened..." -ForegroundColor Red
            }
            
        }else{
            Write-Host "### Pass: Set time automatically is enabled" -ForegroundColor Green
        }    
}else{
    Write-Host "### Info: Automatically time setting is locked because you are a DomainController " -ForegroundColor Yellow
}


Write-Host '### Setting Time-Server...' -ForegroundColor Green

# Configure Local NTP Server with new NTP Server and update the Service
Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers
Set-ItemProperty . 0 $NTPServer
Set-ItemProperty . "(Default)" "0"
Set-Location HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters
Set-ItemProperty . NtpServer $NTPServer
Pop-Location

# Get time vaule from API
if ($timeResponse.statuscode -eq '200') {
    $keyValue = ConvertFrom-Json $Timeresponse.Content | Select-Object -expand "datetime"
    Write-Host '### Got followed data from API: ' -ForegroundColor Green
}

# Set date from API
Set-Date -date $keyValue
Write-Host '### Pass: Set Time and Date from API successfully' -ForegroundColor Green

# Stop the w32tm service - then start ist again
Stop-Service w32time
Start-Service w32time
if ((Get-Service w32time).status -eq 'Running'){
    Write-Host '### Pass: Set Time-Server successfully to'$NTPServer '. Exit now' -ForegroundColor Green
}

