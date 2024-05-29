# Assume $Computer is predefined or use the default local machine name
#$Computer = $env:COMPUTERNAME

# Retrieve page file usage and computer system information
$PageFileResults = Get-CimInstance -Class Win32_PageFileUsage -ComputerName $Computer

# Create a collection to hold channel data
$Channels = @()

# Populate the channel data with page file information
$Channels += [pscustomobject]@{
    'channel'="FilePath";
    'text' = $PageFileResults.Description
}

$Channels += [pscustomobject]@{
    'channel'="TotalSize(in MB)";
    'value' = $PageFileResults.AllocatedBaseSize
}

$Channels += [pscustomobject]@{
    'channel'="CurrentUsage(in MB)";
    'text' = $PageFileResults.CurrentUsage
}

$Channels += [pscustomobject]@{
    'channel'="PeakUsage(in MB)";
    'text' = $PageFileResults.PeakUsage
}

$Channels += [pscustomobject]@{
    'channel'="TempPageFileInUse";
    'text' = $PageFileResults.TempPageFile
}

# Prepare the data for JSON conversion
$prtg = [pscustomobject]@{
    prtg = [pscustomobject]@{
        result = $Channels
    }
}

# Convert to JSON
$JsonResult = $prtg | ConvertTo-Json -Depth 10

# Output JSON result
Write-Output $JsonResult
