#Create SQL database

# The data center and resource name for your resources
$rgname = "PratRGDB"
$location = "West US"
# The logical server name: Use a random value or replace with your own value (do not capitalize)
$servername = "server-$(Get-Random)"
# Set an admin login and password for your database
# The login information for the server
$adminlogin = "ServerAdmin"
$password = "ChangeYourAdminPassword1"
# The ip address range that you want to allow to access your server - change as appropriate
$startip = "0.0.0.0"
$endip = "0.0.0.0"
# The database name
$databasename = "PratDB"


New-AzureRmResourceGroup -Name $resourcegroupname -Location $location

New-AzureRmSqlServer -ResourceGroupName $rgname -ServerName $servername -Location $location -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminlogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

New-AzureRmSqlServerFirewallRule -ResourceGroupName $rgname -ServerName $servername -FirewallRuleName "AllowSome" -StartIpAddress $startip -EndIpAddress $endip

New-AzureRmSqlDatabase  -ResourceGroupName $rgname -ServerName $servername -DatabaseName $databasename -SampleName "AdventureWorksLT" -RequestedServiceObjectiveName "S0"