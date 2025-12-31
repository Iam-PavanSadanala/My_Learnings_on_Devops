$FilePath = "$env:USERPROFILE\Downloads\Ec2_SecurityGroups_Audit_$(Get-Date -Format 'ddMMyyyyHHmmss').csv"
Set-DefaultAWSRegion -Region ap-southeast-1

$Results = @()

try {
    $SecurityGroups = Get-EC2SecurityGroup -ErrorAction Stop

    foreach ($sg in $SecurityGroups) {
        foreach ($rule in $sg.IpPermissions) {
            foreach ($cidr in $rule.Ipv4Ranges) {

                # Only public IPv4 rules
                if ($cidr.CidrIp -ne "0.0.0.0/0") { continue }

                # Defaults
                $Risk        = "Other ports open to the world"
                $RiskLevel   = "Low"
                $FromPort    = $rule.FromPort
                $ToPort      = $rule.ToPort
                $Protocol    = $rule.IpProtocol

                # All traffic
                if ($Protocol -eq "-1") {
                    $Risk      = "All traffic open to the world"
                    $RiskLevel = "High"
                }
                # ICMP
                elseif ($Protocol -eq "icmp") {
                    $Risk      = "ICMP open to the world"
                    $RiskLevel = "Medium"
                }
                # SSH / RDP
                elseif (($FromPort -le 22 -and $ToPort -ge 22) -or
                        ($FromPort -le 3389 -and $ToPort -ge 3389)) {
                    $Risk      = "SSH or RDP open to the world"
                    $RiskLevel = "High"
                }
                # Databases
                elseif (($FromPort -le 3306 -and $ToPort -ge 3306) -or
                        ($FromPort -le 5432 -and $ToPort -ge 5432)) {
                    $Risk      = "Database ports open to the world"
                    $RiskLevel = "Medium"
                }

                $Results += [PSCustomObject]@{
                    Region     = (Get-DefaultAWSRegion)
                    VpcId      = $sg.VpcId
                    GroupId    = $sg.GroupId
                    GroupName  = $sg.GroupName
                    Protocol   = $Protocol
                    FromPort   = $FromPort
                    ToPort     = $ToPort
                    Cidr       = $cidr.CidrIp
                    Risk       = $Risk
                    RiskLevel  = $RiskLevel
                }
            }
        }
    }
}
catch {
    Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

# Display results
$Results | Sort-Object RiskLevel | Format-Table -AutoSize

 $lowcount = ($Results | Where-Object {$_.RiskLevel -eq "Low"}).count
# Summary
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Total Public Findings : $($Results.Count)"
Write-Host "High Risk             : $($Results | Where-Object { $_.RiskLevel -eq "High" }).Count"
Write-Host "Medium Risk           : $($Results | Where-Object { $_.RiskLevel -eq "Medium" }).Count"
Write-Host "Low Risk count        : $lowcount"

# Export to CSV
$Results | Export-Csv -Path $FilePath -NoTypeInformation
Write-Host "`nReport exported to: $FilePath" -ForegroundColor Green

    $lowcount = ($Results | Where-Object {$_.RiskLevel -eq "Low"}).count
