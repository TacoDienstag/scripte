# Assume $Computer is predefined or use the default local machine name
#$Computer = $env:COMPUTERNAME

# Retrieve page file usage and computer system information
$PageFileResults = Get-CimInstance -Class Win32_PageFileUsage -ComputerName $Computer

# Create a collection to hold channel data
$Channels = @()

# Populate the channel data with page file information
$Channels += [pscustomobject]@{
    'channel' = "FilePath";
    'value' = 0  # Since FilePath is a string, provide a dummy numeric value if necessary
    'text' = $PageFileResults.Description
}
$Channels += [pscustomobject]@{
    'channel' = "TotalSize(in MB)";
    'value' = $PageFileResults.AllocatedBaseSize
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
