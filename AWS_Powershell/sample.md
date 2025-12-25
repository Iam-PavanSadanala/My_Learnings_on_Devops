```bash 
$cfnlist = Get-CFNStack | % { Get-CFNStackResourceList -StackName $_.StackName } ```

1. Get-CFNStack
Fetches all CloudFormation stacks in the currently configured AWS region/account.
Each item in the output is a stack object with properties like:

StackName
StackId
StackStatus
etc.

2. | % { ... }
% is an alias for ForEach-Object. It iterates over each stack object from Get-CFNStack.
Inside the loop: Get-CFNStackResourceList -StackName $_.StackName
For each stack, it calls Get-CFNStackResourceList to retrieve the resources inside that stack.
Typical resource properties returned include:

LogicalResourceId
PhysicalResourceId
ResourceType
ResourceStatus

3. Assignment to $cfnlist
$cfnlist becomes a collection of resource lists—one list per stack.
In other words, you’ll likely end up with a nested array (an array of arrays) unless PowerShell auto-flattens them based on how the provider emits objects.


```bash
$t = Get-CFNStack | ? StackName -ILike '*BodyKey*' | Select-Object StackName ```

Breakdown

1. Get-CFNStack
Retrieves all CloudFormation stacks that your current AWS profile/credentials can see in the default region (or the region set via Initialize-AWSDefaultConfiguration/Set-AWSCredential).
Output: a collection of stack objects with properties like StackName, StackId, StackStatus, etc.


2. | ? StackName -ILike '*BodyKey*'
? is an alias for Where-Object. This filters the incoming stack objects.

StackName is the property being tested.
-ILike performs a case-insensitive wildcard match.
'*BodyKey*' means: keep stacks whose names contain the substring “BodyKey” anywhere (e.g., prod-BodyKey-api, BODYKEY-stack, etc.).

Equivalent expanded form:
PowerShell| Where-Object { $_.StackName -like '*BodyKey*' }  # case-sensitive| Where-Object { $_.StackName -ilike '*BodyKey*' } # case-insensitiveShow more lines


3. | Select-Object StackName
Projects only the StackName property from the filtered stacks.
Output: objects containing just the StackName property (not plain strings).


4. $t = ...
Assigns the resulting list (could be 0, 1, or many items) to the variable $t.

-----------------------

If you want to get details of the first 5 objects from the output of Get-CFNStack, you can use the Select-Object cmdlet with the -First parameter.

```csv
Example:
PowerShellGet-CFNStack | Select-Object -First 5
```