# Capture your Okta credentials
$Credential = Get-Credential
# Specify the Okta application name of the AWS account you want to access
$OktaApplicationName = "AWS APAC SEA Shared PREPROD"
# Authenticate, go through MFA process, and store credentials in default AWS CLI file
\\pool0.isilon-ada.intranet.local\automation\scripts\aws\iam\Get-AWSTemporaryCredential.ps1 -UserId $Credential.UserName -Password $Credential.GetNetworkCredential().Password -OktaApplicationName $OktaApplicationName -Sms -Interactive -AsPlainText -StoreAs "default" -Profile "$(Resolve-Path -Path '~/')/.aws/credentials" -Suppress


