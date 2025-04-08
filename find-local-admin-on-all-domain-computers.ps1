$Computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

if ($Computers.Count -eq 0) {
    Write-Host "No computers found in the domain!"
} else {
    $Computers | ForEach-Object {
        $Computer = $_
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
            Write-Host "Checking: $Computer"
            try {
                $Admins = Invoke-Command -ComputerName $Computer -ScriptBlock {
                    Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
                } -ErrorAction Stop
                [PSCustomObject]@{ ComputerName = $Computer; Admins = ($Admins -join ", ") }
            } catch {
                Write-Host "Failed to retrieve data from $Computer"
            }
        } else {
            Write-Host "$Computer is not reachable!"
        }
    } | Export-Csv -Path C:\AdminsList.csv -NoTypeInformation
}