﻿#BossWiz Automation Script
#createDB.ps1
#May 18/2012


#Creates and populates a new database using our specifications
#Writes the newly created infomation to its_constants.php
$accountName = $args[0]
$append = "bw_"
$dbname = $append + $accountName
$liveServer = $false;
[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

#Creates a connection to the server.  Change $liveServer = $true to switch from the dev database to live.
if($liveServer)
    {
        $connStr ="server=mysqllive;Persist Security Info=false;user id=" + "bw_user" + ";pwd=" + "XXXXXXXXXXX" + ";"
    }
else
    {
        $connStr ="server=mysqldev;Persist Security Info=false;user id=" + "bosswiz" + ";pwd=" + "XXXXXXXXXXX" + ";"
    }

$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)

#Open connection
$conn.Open()

#Drops database if it currently exists
$cmd = New-Object MySql.Data.MySqlClient.MySqlCommand
$cmd.Connection  = $conn
$cmd.CommandText = "DROP DATABASE IF EXISTS " + $dbname
$cmd.ExecuteNonQuery()

#Create the new database
$cmd.CommandText = 'CREATE DATABASE `' + $dbname + '`'
$cmd.ExecuteNonQuery()

#Load the sql file
$sql = (Get-Content $pwd\NewClient.sql) | Out-String
$cmd.CommandText = "USE $dbname"
$cmd.ExecuteNonQuery()
$cmd.CommandText = $sql
$cmd.ExecuteNonQuery()


$sql1 = (Get-Content $pwd\stopTimeWorkerInsert.sql) | Out-String
$cmd.CommandText = $sql1
$cmd.ExecuteNonQuery()
$sql2 = (Get-Content $pwd\stopTimeWorkerUpdate.sql) | Out-String
$cmd.CommandText = $sql2
$cmd.ExecuteNonQuery()
$sql3 = (Get-Content $pwd\WorkerTimerProcedure.sql) | Out-String
$cmd.CommandText = $sql3
$cmd.ExecuteNonQuery()
$sql4 = (Get-Content $pwd\bitm_actions_time_trigger.sql) | Out-String
$cmd.CommandText = $sql4
$cmd.ExecuteNonQuery()


#Close connection
$conn.Close()

#-----------------------------------------------------------------
#Write the server infomation to its_constants.php
#-----------------------------------------------------------------

$fileName = "$pwd\final\its_common\its_constants.php"
$userName = $append + $accountName
$length = 8
$numberOfNonAlphanumericCharacters = 0

#Generate a random password.  Not currently used.
Add-Type -Assembly System.Web
$password = [Web.Security.Membership]::GeneratePassword($length,$numberOfNonAlphanumericCharacters)

#Searchs for a token then replaces that token with the below text.

if($liveServer)
    {
        (Get-Content $fileName )|   ForEach-Object { $_ -replace "//New Client//",
"
    case ""$accountName"":
      date_default_timezone_set(""America/Edmonton"");
      `$weatherLocation = 'CAAB0049';
         
      //constants for db server access
      define(""MySQL_SERVER_NAME"",""mysqllive"");
	  define(""MySQL_DB_NAME"",""$dbname"");
	  define(""MySQL_USER_NAME"",""bw_user"");
      define(""MySQL_PASSWORD"",""XXXXXXXXXXX"");  


	  //SMS Gateway Account Information
	  define(""ACCOUNT_KEY"", ""XXXXXXXXXXX"");
	  define(""SMS_URL"", ""http://smsgateway.ca/sendsms.aspx?"");
	  define(""ID_PREFIX"", ""BW:"");
	  break;
      
      //New Client//
  
  " } | Set-Content $fileName
  }
  
  else
  {
  (Get-Content $fileName )|   ForEach-Object { $_ -replace "//New Client//",
"
    case ""$accountName"":
      date_default_timezone_set(""America/Edmonton"");
      `$weatherLocation = 'CAAB0049';
         
      //constants for db server access
      define(""MySQL_SERVER_NAME"",""mysqldev"");
	  define(""MySQL_DB_NAME"",""$dbname"");
	  define(""MySQL_USER_NAME"",""bosswiz"");
      define(""MySQL_PASSWORD"",""XXXXXXXXXXX"");  


	  //SMS Gateway Account Information
	  define(""ACCOUNT_KEY"", ""XXXXXXXXXXX"");
	  define(""SMS_URL"", ""http://smsgateway.ca/sendsms.aspx?"");
	  define(""ID_PREFIX"", ""BW:"");
	  break;
      
      //New Client//
      " } | Set-Content $fileName
  }
  
