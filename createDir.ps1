#BossWiz Automation Script
#createDir.ps1
#May 18/2012

#Creates directorys and copies a few image files for a new client
#Recieves account name as a command line paramater.

$path = $pwd
$accountName = $args[0] #First argument in the command line
$fullcontrol = "FullControl"
$imgFilePath = $accountName + "_Logo_Title"

#----------------------------------------------------
#Creates folders using the users account name.
#----------------------------------------------------

New-Item $path\final\its_contracts\contracts\$accountName -type directory
New-Item $path\final\its_routes\stops_photos\$accountName -type directory
New-Item $path\final\its_accounting\uploads\$accountName -type directory
New-Item $path\final\its_admin\pdfs\$accountName -type directory
New-Item $path\final\its_admin\photos\$accountName -type directory

#Get parents folder permissions and pass those to child
$acl = (Get-Item $path).GetAccessControl("Access")
Set-Acl "$path\final\its_contracts\contracts\$accountName" $acl
Set-Acl "$path\final\its_routes\stops_photos\$accountName" $acl
Set-Acl "$path\final\its_accounting\uploads\$accountName" $acl
Set-Acl "$path\final\its_admin\pdfs\$accountName" $acl
Set-Acl "$path\final\its_admin\photos\$accountName" $acl

Copy-Item $path\final\images\site\logos\Sales_Logo_Title.jpg $path\final\images\site\logos\$imgFilePath.jpg
for ($i = 1; $i -le 3;$i++){
$salesFilePath = $accountName + $i
Copy-Item $path\final\images\site\splash\Sales$i.jpg $path\final\images\site\splash\$salesFilePath.jpg
}

#----------------------------------------------------
#Creates index.php for the account
#----------------------------------------------------

New-Item $path\$accountName -type directory
New-Item $path\$accountName\index.php -type file
$fileName = "$path\$accountName\index.php"
$text = "<?php
  setcookie(""AccountName"",""$accountName"",0,""/"");
  if(session_id()==""""){
    session_start();
  } 

  unset(`$_SESSION['USER_LEVEL']); //switching client accounts logs out user.
  `$_SESSION['its_userid']  = """";
  `$_SESSION['AccountName'] = ""$accountName"";

  header('Location: ../final/its_admin/index.php');
?>"


[System.IO.File]::WriteAllText($fileName, $text)



