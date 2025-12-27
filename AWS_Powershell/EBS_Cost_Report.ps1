$OutputFilePath = "$env:USERPROFILE\Downloads\EBS_cost_report_$(Get-Date -Format 'yyyyMMdd').csv"
$regions = (Get-Ec2Region).RegionName

foreach ($region in $regions) {
Set-DefaultAWSRegion -Region ap-southeast-1
$results = @()

Try{

$Instance_IDs=((Get-EC2Instance -Region ap-southeast-1 -Filter @{Name = "instance-state-name" ; Values = "running"}).Instances).InstanceId

foreach ($id in $Instance_ids) {

  $volumes=Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $id }


     foreach ( $vol in $volumes){
     $results+= [PSCustomObject] @{

     InstanceID = $id
     VolumeID = $vol.VolumeId
     Type = $vol.VolumeType
     Size = $vol.Size
     }
    }
  }
}
catch{
write-output "caught exception $($_.Exception.Message)"
}
}

$results | Export-Csv -Path $OutputFilePath
