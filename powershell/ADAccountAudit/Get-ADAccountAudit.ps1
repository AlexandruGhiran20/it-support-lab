param(
    [string]$SearchBase = "OU=Lab Users,DC=corp,DC=itlab,DC=test",
    [string]$Path = "C:\Scripts\ADAccountAudit.csv"
)
$TempPath = $null
try {
    $Users = @(Get-ADUser -Filter * ` -SearchBase $SearchBase ` -Properties Department -ErrorAction Stop)
    if ($Users.Count -eq 0) {
        Write-Warning "No users found in '$SearchBase'. Existing report unchanged."
        return
    }
    $AuditRecords = foreach ($User in $Users) {

        $GroupNames = Get-ADPrincipalGroupMembership -Identity $User -ErrorAction Stop | Where-Object { $_.GroupCategory -eq "Security" }

        $UserRecord = [pscustomobject]@{
            Name           = $User.Name
            UserName       = $User.SamAccountName
            Enabled        = $User.Enabled
            Department     = $User.Department
            SecurityGroups = $GroupNames.Name -join "; "
        }

        $UserRecord
    }
    $OutputDirectory = Split-Path -Path $Path -Parent

    if (-not $OutputDirectory) {
        $OutputDirectory = "."
    }

    if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
        throw "Output directory '$OutputDirectory' does not exist."
    }

    if (Test-Path -LiteralPath $Path -PathType Container) {
        throw "Output path '$Path' is a directory, not a file."
    }

    $TempPath = Join-Path $OutputDirectory (
        "ADAccountAudit-{0}.tmp" -f [guid]::NewGuid().ToString("N")
    )

    $AuditRecords | Export-Csv -LiteralPath $TempPath ` -NoTypeInformation -Encoding UTF8 -ErrorAction Stop

    Move-Item -LiteralPath $TempPath -Destination $Path ` -Force -ErrorAction Stop

    $TempPath = $null

    Write-Host "Success: $(@($AuditRecords).Count) accounts exported to '$Path'."
}
catch {
    Write-Error "Audit failed: $($_.Exception.Message)"
}
finally {
    if ($TempPath -and (Test-Path -LiteralPath $TempPath)) {
        Remove-Item -LiteralPath $TempPath -Force -ErrorAction SilentlyContinue
    }

}
