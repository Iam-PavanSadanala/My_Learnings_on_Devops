$filepath = "$env:USERPROFILE\Downloads\Unused_EBS_report_$(Get-Date -Format "ddMMyyyyHHmmss").csv"

$volumelist = @()

$regions = (Get-Ec2Region).RegionName
foreach($region in $regions) {
    Set-DefaultAWSRegion -Region $region
try{
    $volumes = Get-EC2Volume -ErrorAction Stop

    foreach ($vol in $volumes) {

        #calculate days since last attached
            $AgeDays = (New-TimeSpan -Start $vol.CreateTime -End (Get-Date)).Days

        if ($vol.State -eq "in-use") {
            $Cleanup_Recommendation = "In Use"
        } else {

            if ($AgeDays -gt 30) {
                $Cleanup_Recommendation = "Safe to delete"
            }
            else {
                $Cleanup_Recommendation = "Review required"
            }
        }


        $volumelist += [PSCustomObject] @{
            Region = $region
            VolumeID = $vol.VolumeID
            Size_GB = $vol.Size
            State = $vol.State
            AgeDays = $AgeDays
            Cleanup_Recommendation = $Cleanup_Recommendation
        }
    }
}
catch{
    Write-Host "caught exception in $region which is $($_.Exception.Message)" -ForegroundColor Red
}
}
    # Count of Total Volumes
   Write-Host "Total Volumes are : $($volumelist.Count)" -ForegroundColor Cyan
    #count of Unused Volumes
   Write-Host "Unused Volumes are :$(($volumelist | Where-Object { $_.State -eq "available" }).Count)" -ForegroundColor Yellow
    #Volumes recommended for deletion
    $Volumes_recommended_for_deletion = $($volumelist | Where-Object {$_.Cleanup_Recommendation -eq "Safe to Delete" } | Select-Object VolumeID)
    if ( $Volumes_recommended_for_deletion ) {
        Write-Host "Volumes recommended for deletion are :" -ForegroundColor Green
        $Volumes_recommended_for_deletion | ForEach-Object { Write-Host $_.VolumeID -ForegroundColor Cyan }
    } else {
        Write-Host "No Volumes recommended for deletion" -ForegroundColor Green
    }

    $volumelist | Export-Csv -Path $filepath -NoTypeInformation
