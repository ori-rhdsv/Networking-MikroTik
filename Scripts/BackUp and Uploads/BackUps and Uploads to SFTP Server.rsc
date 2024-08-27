# === BackUps and Uploads to SFTP Server by RHDSV
## Create or add script with import:
## Its can be used with trigger like using another scripts and or netwatch and or scheduler
## For Using This Script Please Customize Using Your Own Params:
## In the add script Sections:
### 1. name="BackUps and Uploads to SFTP Server" equals to: name="your script name"
### 2. owner=rh					 equals to: owner=your mikrotik device systems user
## In the Variables Sections:
### 3. backuppass \"\" 	 equals to: backuppass \"your backup password\"
### 4. encryptionmethod1 \"aes-sha256\"		 equals to: encryptionmethod1 \"aes-sha256\"	
### 5. encryptionmethod2 \"rc4\" 		 equals to: encryptionmethod2 \"rc4\"
### 6. sftpuser \"\"		 equals to: sftpuser \"your sftp username\"
### 7. sftppassword \"\"	 equals to: sftppassword \"your sftp password\"
### 8. sftpip \"\"			 equals to: sftpip \"your sftp server ip\"
### 9.a. sftpdirpath \"\"		 equals to: sftpdirpath \"your directory path on sftp server\"
### 9.b. notes:
####      - your directory path on sftp server without opening and closing slash
####      - if its using subdiretory in a directory just using single slash in between the directory and its sub directory
####
### 10. sftpport \"\"				equals to: sftpport \"your sftp applications port number on the server\"	
## In the Generating Backup and Files Sections:
#### 11. encryption=\$\"encryptionmethod2\"	equals to: encryption=\$\"encryption method you choose between encryptionmethod1 or encryptionmethod2\" 
## Thats its.
## Please feel free to contacts or submit issue if not working or having troubles and would be welcome also if there are any questions:
## https://rhdsv.com/contactus
## https://github.com/ori-rhdsv
# BackUps and Uploads to SFTP Server by RHDSV ===
## Codes:

add comment="Ori AKA RH" dont-require-permissions=yes name=\
    "BackUps and Uploads to SFTP Server" owner=rh policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    ## === BackUps and Uploads to SFTP Server\r\
    \n\r\
    \n:local systemidentityname [/system identity get name]\r\
    \n:local rosversion [/system resource get version]\r\
    \n:local textfile\r\
    \n:local backupfile\r\
    \n:local backuppass \"\"\r\
    \n:local encryptionmethod1 \"aes-sha256\"\r\
    \n:local encryptionmethod2 \"rc4\"\r\
    \n:local sftpuser \"\"\r\
    \n:local sftppassword \"\"\r\
    \n:local sftpip \"\"\r\
    \n:local sftpdirpath \"\"\r\
    \n:local sftpport \"\"\r\
    \n:local sftplogbackup \"sftplogbackup.log\"\r\
    \n:local sftplogtext \"sftplogtext.log\"\r\
    \n:local backupdate [/system clock get date]\r\
    \n:local uploadbackupstatus 0\r\
    \n:local uploadtextstatus 0\r\
    \n:log info \"== Starting BackUps.... \"\r\
    \n:set textfile (\$\"systemidentityname\" . \"_\" . \$\"backupdate\" . \".\
    rsc\")\r\
    \n:set backupfile (\$\"systemidentityname\" . \"_\" . \$\"backupdate\" .  \
    \".backup\")\r\
    \n:local sftpuploads1 \"/tool fetch upload=yes url=\\\"sftp://\$sftpip/\$s\
    ftpdirpath/\$backupfile\\\" port=\$sftpport user=\$sftpuser password=\$sft\
    ppassword src-path=\$backupfile mode=sftp keep-result=no as-value\"\r\
    \n:local sftpuploads2 \"/tool fetch upload=yes url=\\\"sftp://\$sftpip/\$s\
    ftpdirpath/\$textfile\\\" port=\$sftpport user=\$sftpuser password=\$sftpp\
    assword src-path=\$textfile mode=sftp keep-result=no as-value\"\r\
    \n\r\
    \n\r\
    \n## Generating BackUp and Text Files\r\
    \n:log info \"Generating BackUp and Text File.... \"\r\
    \n:log info \"RouterOS Version: \$rosversion\"\r\
    \n:delay 2s\r\
    \n:if (\$rosversion~\"^7.\") do={\r\
    \n:execute [/export compact show-sensitive file=\$\"textfile\"]\r\
    \n} else={\r\
    \n:execute [/export file=\$\"textfile\"]\r\
    \n}\r\
    \n:execute [/system backup save encryption=\$\"encryptionmethod2\" passwor\
    d=\$\"backuppass\" name=\$\"backupfile\"]\r\
    \n:delay 5s\r\
    \n:log info \"... BackUp and Text Files Created\"\r\
    \n:delay 2s\r\
    \n\r\
    \n\r\
    \n## Sending Text File\r\
    \n:log info \"Sending Text File to SFTP Server...\"\r\
    \n:delay 15s\r\
    \n\r\
    \n:execute file=\$\"sftplogtext\" script=\$\"sftpuploads2\"\r\
    \n:delay 30s\r\
    \n:local sftplogtextresults [/file get [find name=\"\$sftplogtext.txt\"] c\
    ontents]\r\
    \n:delay 5s\r\
    \n\r\
    \n:if (\$sftplogtextresults~\"finished\") do={\r\
    \n:log info \"... Text Successfully Uploaded\"\r\
    \n} else={\r\
    \n:if (\$sftplogtextresults~\"^fail\") do={\r\
    \n:log info \"... Text Upload Failed\"\r\
    \n:delay 2s\r\
    \n:set \$uploadtextstatus (\$uploadtextstatus+1)\r\
    \n:log info \"Prepare for Re-Uploading Text File... \"\r\
    \n:log info \$uploadtextstatus\r\
    \n} else={\r\
    \n:log info \"... Text Successfully Uploaded\"\r\
    \n}}\r\
    \n\r\
    \n:delay 10s\r\
    \n\r\
    \n:while (\$uploadtextstatus>0) do={\r\
    \n:log info \"Re-Uploading Text File...\"\r\
    \n:delay 30s\r\
    \n:execute file=\$\"sftplogtext\" script=\$\"sftpuploads2\"\r\
    \n:local sftplogtextresults [/file get [find name=\"\$sftplogtext.txt\"] c\
    ontents]\r\
    \n:delay 2s\r\
    \n:if (\$sftplogtextresults~\"finished\") do={\r\
    \n:log info \"... Re-Upload Text Successfully Uploaded\"\r\
    \n:set \$uploadtextstatus (\$uploadtextstatus-1)\r\
    \n} \r\
    \n:if (\$sftplogtextresults~\"^fail\") do={\r\
    \n:log info \"... Re-Upload Text Failed\"\r\
    \n:delay 2s\r\
    \n:log info \"Prepare for Re-Uploading Text File... \"\r\
    \n:log info \$uploadtextstatus\r\
    \n} else={\r\
    \n:log info \"... Re-Upload Text Successfully Uploaded\"\r\
    \n:set \$uploadtextstatus (\$uploadtextstatus-1)\r\
    \n}}\r\
    \n:log info \"... Sending Text File Completed\"\r\
    \n:delay 5s\r\
    \n\r\
    \n\r\
    \n## Sending BackUp File\r\
    \n:log info \"Sending BackUp File to SFTP Server...\"\r\
    \n:delay 15s\r\
    \n\r\
    \n:execute file=\$\"sftplogbackup\" script=\$\"sftpuploads1\"\r\
    \n:delay 30s\r\
    \n:local sftplogbackupresults [/file get [find name=\"\$sftplogbackup.txt\
    \"] contents]\r\
    \n:delay 5s\r\
    \n\r\
    \n:if (\$sftplogbackupresults~\"finished\") do={\r\
    \n:log info \"... BackUp Successfully Uploaded\"\r\
    \n} else={\r\
    \n:if (\$sftplogbackupresults~\"^fail\") do={\r\
    \n:log info \"... BackUp Upload Failed\"\r\
    \n:delay 2s\r\
    \n:set \$uploadbackupstatus (\$uploadbackupstatus+1)\r\
    \n:log info \"Prepare for Re-Uploading Backup File... \"\r\
    \n:log info \$uploadbackupstatus\r\
    \n} else={\r\
    \n:log info \"... BackUp Successfully Uploaded\"\r\
    \n}}\r\
    \n\r\
    \n:delay 10s\r\
    \n\r\
    \n:while (\$uploadbackupstatus>0) do={\r\
    \n:log info \"Re-Uploading BackUp File...\"\r\
    \n:delay 30s\r\
    \n:execute file=\$\"sftplogbackup\" script=\$\"sftpuploads1\"\r\
    \n:local sftplogbackupresults [/file get [find name=\"\$sftplogbackup.txt\
    \"] contents]\r\
    \n:delay 2s\r\
    \n:if (\$sftplogbackupresults~\"finished\") do={\r\
    \n:log info \"... Re-Upload BackUp Successfully Uploaded\"\r\
    \n:set \$uploadbackupstatus (\$uploadbackupstatus-1)\r\
    \n} \r\
    \n:if (\$sftplogbackupresults~\"^fail\") do={\r\
    \n:log info \"... Re-Upload BackUp Failed\"\r\
    \n:delay 2s\r\
    \n:log info \"Prepare for Re-Uploading BackUp File... \"\r\
    \n:log info \$uploadbackupstatus\r\
    \n} else={\r\
    \n:log info \"... Re-Upload BackUp Successfully Uploaded\"\r\
    \n:set \$uploadbackupstatus (\$uploadbackupstatus-1)\r\
    \n}}\r\
    \n:log info \"... Sending BackUp File Completed\"\r\
    \n:delay 5s\r\
    \n\r\
    \n\r\
    \n## All BackUp Status\r\
    \n:delay 2s\r\
    \n:log info \"... All Text and BackUp Files Successfully Uploaded\"\r\
    \n\r\
    \n\r\
    \n## Removing Temporary Uploads Files\r\
    \n:delay 2s\r\
    \n:log info \"... Removing Temporary Files Thats Already Uploaded\"\r\
    \n:delay 5s\r\
    \n/file remove \$sftplogbackup\r\
    \n/file remove \$sftplogtext\r\
    \n/file remove \$backupfile \r\
    \n/file remove \$textfile\r\
    \n\r\
    \n\r\
    \n## Close BackUp\r\
    \n:delay 10s\r\
    \n:log info \".... BackUps Finished==\"\r\
    \n\r\
    \n### BackUps and Uploads to SFTP Server ==="
