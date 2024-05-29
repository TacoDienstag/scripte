# Assume $Computer is predefined or use the default local machine name
#$Computer = $env:COMPUTERNAME

# Retrieve page file usage and computer system information
$PageFileResults = Get-CimInstance -Class Win32_PageFileUsage -ComputerName $Computer
$ComputerSystemResults = Get-CimInstance -Class Win32_ComputerSystem -ComputerName $Computer


# Decide if Pagefile is auto or manuell and set Int according to bool
if ($ComputerSystemResults.AutomaticManagedPagefile == True)
{
    $PagefileMode = 1
}else{
    $PagefileMode = 0
}

# Calculate the percentage of free pagefile size
$PageFileUsedPercentage = ($PageFileResults.CurrentUsage / $PageFileResults.AllocatedBaseSize) * 100


# Create a collection to hold channel data
$Channels = @()

# Populate the channel data with page file information
$Channels += [pscustomobject]@{
    'channel' = "FilePath";
    'value' = 0  # Since FilePath is a string, provide a dummy numeric value if necessary
    'text' = $PageFileResults.Description
}
$Channels += [pscustomobject]@{
   'channel' = "PagefileMode(0 = Manuell, 1 = Auto)";
   'value' = $PagefileMode
}
$Channels += [pscustomobject]@{
    'channel' = "TotalSize(in MB)";
    'value' = $PageFileResults.AllocatedBaseSize
}
$Channels += [pscustomobject]@{
    'channel' = "FreePageFilesize(in %)";
    'value' = $PageFileUsedPercentage
    'unit' = "Percent";
    'float' = 1
    'limitMaxWarning' = "75";
    'limitMaxError' = "90";
}
$Channels += [pscustomobject]@{
    'channel' = "CurrentUsage(in MB)";
    'value' = $PageFileResults.CurrentUsage
}
$Channels += [pscustomobject]@{
    'channel' = "PeakUsage(in MB)";
    'value' = $PageFileResults.PeakUsage
}
$Channels += [pscustomobject]@{
    'channel' = "TempPageFileInUse";
    'value' = [int]$PageFileResults.TempPageFile  # Assuming this returns a boolean, convert it to int
}
# Prepare the data for JSON conversion
$prtg = [pscustomobject]@{
    prtg = [pscustomobject]@{
        result = $Channels
    }
}

# Convert to JSON
#$JsonResult = $prtg | ConvertTo-Json -Depth 10
$prtg | ConvertTo-Json -Depth 10

# Output JSON result
#Write-Output $JsonResult
