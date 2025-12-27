# 1. Set the AWS region
Set-DefaultAWSRegion -Region us-east-1

# 2. Define CSV output file path with today’s date
$FilePath = "$env:USERPROFILE\Downloads\IAM_Keys_Audit_$(Get-Date -Format 'yyyyMMdd').csv"

# 3. Get all IAM users in the account
$Users = Get-IAMUserList

# 4. Create an empty array to store results
$Results = @()

# 5. Loop through each IAM user
foreach ($User in $Users) {

    # 6. Get access keys for the current user
    $Keys = Get-IAMAccessKey -UserName $User.UserName

    # 7. Loop through each access key
    foreach ($Key in $Keys) {

        # 8. Get last-used details for the access key
        $LastUsedInfo = Get-IAMAccessKeyLastUsed -AccessKeyId $Key.AccessKeyId
        $LastUsedDate = $LastUsedInfo.AccessKeyLastUsed.LastUsedDate

        # 9. AWS returns 01-01-0001 if key was never used → convert to null
        if ($LastUsedDate -eq [DateTime]::MinValue) {
            $LastUsedDate = $null
        }

        # 10. Calculate how old the key is (in days)
        $KeyAgeDays = (New-TimeSpan -Start $Key.CreateDate -End (Get-Date)).Days

        # 11. Default risk reason
        $RiskReason = "None"

        # 12. Check if key is older than 90 days
        if ($Key.Status -eq "Active" -and $KeyAgeDays -gt 90) {
            $RiskReason = "Key older than 90 days"
        }

        # 13. Check if key was never used
        if ($Key.Status -eq "Active" -and -not $LastUsedDate) {
            $RiskReason = "Never used"
        }

        # 14. Check if key not used in last 60 days
        if ($Key.Status -eq "Active" -and $LastUsedDate) {
            $InactiveDays = (New-TimeSpan -Start $LastUsedDate -End (Get-Date)).Days
            if ($InactiveDays -gt 60) {
                $RiskReason = "Not used in last 60 days"
            }
        }

        # 15. Add details to results array
        $Results += [PSCustomObject]@{
            UserName     = $User.UserName
            AccessKeyId  = $Key.AccessKeyId
            Status       = $Key.Status
            CreateDate   = $Key.CreateDate
            LastUsedDate = if ($LastUsedDate) { $LastUsedDate } else { "Never Used" }
            RiskReason   = $RiskReason
        }
    }
}

# 16. Show only risky keys on screen
$Results |
Where-Object { $_.RiskReason -ne "None" } |
Format-Table -AutoSize

# 17. Export full report to CSV
$Results | Export-Csv -Path $FilePath -NoTypeInformation

# 18. Confirmation message
Write-Host "IAM Access Key audit report created at:" $FilePath -ForegroundColor Green
