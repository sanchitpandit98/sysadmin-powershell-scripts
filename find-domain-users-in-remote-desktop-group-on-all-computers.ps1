$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name


$results = @()

foreach ($computer in $computers) {
    Write-Host "Checking $computer..." -ForegroundColor Cyan
    try {
        $groupMembers = Invoke-Command -ComputerName $computer -ScriptBlock {
            try {
                $group = [ADSI]"WinNT://$env:COMPUTERNAME/Remote Desktop Users"
                $group.Members() | ForEach-Object {
                    $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
                }
            } catch {
                "Error reading group"
            }
        } -ErrorAction Stop

        foreach ($member in $groupMembers) {
            $results += [PSCustomObject]@{
                ComputerName = $computer
                Member       = $member
            }
        }

    } catch {
        $results += [PSCustomObject]@{
            ComputerName = $computer
            Member       = "Access Failed or Offline"
        }
    }
}


$csvPath = "$env:USERPROFILE\Desktop\RemoteDesktopUsers_Report.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "`n Done! Report saved to: $csvPath" -ForegroundColor Green