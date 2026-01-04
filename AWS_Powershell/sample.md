## 1. Get a List of Resources for All CloudFormation Stacks

```powershell
$cfnlist = Get-CFNStack | % { Get-CFNStackResourceList -StackName $_.StackName }

Explanation:

Get-CFNStack: Retrieves all CloudFormation stacks in the currently configured AWS region/account. The output includes properties such as:

StackName
StackId
StackStatus

| % { ... }: The % is an alias for ForEach-Object, which iterates over each stack object retrieved by Get-CFNStack.

Inside the loop, the Get-CFNStackResourceList cmdlet is used to fetch resources inside each stack.
Typical resource properties include:
LogicalResourceId
PhysicalResourceId
ResourceType
ResourceStatus

$cfnlist: Stores the resulting list of resources. If there are multiple stacks, this will likely result in a nested array (one array per stack).
```
-------

## 2. Filter CloudFormation Stacks by Name
```powershell
$t = Get-CFNStack | ? StackName -ILike '*BodyKey*' | Select-Object StackName


Explanation:
Get-CFNStack: Retrieves all CloudFormation stacks available in the current AWS region/account.

| ? StackName -ILike '*BodyKey*': The ? is an alias for Where-Object. This filters stacks where the StackName property matches the wildcard pattern '*BodyKey*'. The -ILike operator performs a case-insensitive match, meaning it will match any stack whose name contains "BodyKey", regardless of case.

Example stack names that will match: prod-BodyKey-api, BODYKEY-stack, etc.

| Select-Object StackName: Selects only the StackName property from the filtered stacks, simplifying the output to show only the stack names.

$t: Assigns the filtered stack names to the variable $t.
```
------

## 3. Retrieve the First 5 CloudFormation Stacks
```powershell
Get-CFNStack | Select-Object -First 5

Explanation:
Get-CFNStack: Retrieves all CloudFormation stacks in the configured region/account.

| Select-Object -First 5: Limits the output to the first 5 CloudFormation stack objects.

```
----
```powershell
PS C:\Users\aiuprc5\Downloads> Get-Alias ?

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           % -> ForEach-Object
Alias           ? -> Where-Object
Alias           h -> Get-History
Alias           r -> Invoke-History
```
