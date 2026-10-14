# Active Directory Account Audit Tool

A read-only PowerShell script that inventories user accounts in a specified Active Directory organisational unit (OU) and exports a CSV report. Developed and tested as part of a Windows Server 2025 / Windows 11 IT support home lab.

## Purpose

This tool provides a quick overview of employee accounts for routine IT administration and review. It reports account state, department and security group memberships without changing any Active Directory objects.

## Features

- Retrieves user accounts from a configurable OU, including nested OUs (the default AD search scope is subtree).
- Includes each account's name, logon name, enabled/disabled state and department.
- Retrieves security group memberships using `Get-ADPrincipalGroupMembership` and filters for security groups.
- Exports one CSV row per user, joining multiple group names into a semicolon-separated field.
- Accepts optional OU and output-path parameters with convenient lab defaults.
- Handles Active Directory query, group-lookup and CSV export errors.
- Writes the CSV to a temporary file before moving it to the destination, reducing the risk of replacing a valid report after a failed query or export.
- Leaves the previous report unchanged if the selected OU contains no users, and displays a warning.

## Requirements

- Windows PowerShell with the **ActiveDirectory** module available (provided by AD DS administration tools / RSAT).
- Access to the target Active Directory domain and sufficient permissions to read the relevant accounts and groups.
- Permission to write to the selected output directory; **the directory must already exist**.
- Script execution permitted by the machine's applicable PowerShell execution policy.

The script was tested on `DC01`, a Windows Server 2025 domain controller in the isolated `corp.itlab.test` lab. Domain administrator privileges are **not inherently required** for ordinary read-only AD queries; permissions depend on the environment.

## Usage

Save `Get-ADAccountAudit.ps1` and run it in PowerShell on a machine with access to Active Directory.

**Run using the lab defaults:**

```powershell
.\Get-ADAccountAudit.ps1
```

Default parameters:

| Parameter | Default | Purpose |
| --- | --- | --- |
| `-SearchBase` | `OU=Lab Users,DC=corp,DC=itlab,DC=test` | Distinguished name of the OU to audit |
| `-Path` | `C:\Scripts\ADAccountAudit.csv` | Destination CSV file |

**Audit a different OU and choose an output file:**

```powershell
.\Get-ADAccountAudit.ps1 `
    -SearchBase "OU=Lab Users,DC=corp,DC=itlab,DC=test" `
    -Path "C:\Scripts\CustomAudit.csv"
```

The output directory, such as `C:\Scripts`, must exist before execution. Existing reports at the chosen output path are replaced after a successful export.

## Report format

The CSV contains the following columns:

| Column | Description |
| --- | --- |
| `Name` | Display name of the user |
| `UserName` | `SamAccountName` (logon name) |
| `Enabled` | Whether the AD account is enabled |
| `Department` | Department attribute; may be blank |
| `SecurityGroups` | Direct security group names, separated by `; ` |

Example (illustrative lab data):

```csv
"Name","UserName","Enabled","Department","SecurityGroups"
"Alex Morgan","alex.morgan","True","","Domain Users"
"Jamie Reed","jamie.reed","True","Sales","Domain Users; GG_Sales"
```

The `SecurityGroups` field is formatted for human-readable reporting; it is not a calculation of effective access rights.

## Error handling and limitations

- Active Directory lookup and export errors generate an error message. A failed account/group query prevents the normal report export.
- Invalid or missing output directories are reported rather than automatically created.
- An **empty OU** produces a warning and does not overwrite the last report. Check the script output and report timestamp before treating an existing CSV as current.
- Membership reporting uses `Get-ADPrincipalGroupMembership`. It does **not** recursively expand nested groups, determine effective permissions, or audit access to files and applications.
- The temporary-file workflow protects against common retrieval/export failures but is **not** a full transactional or atomic file-replacement guarantee.
- The script is **read-only with respect to Active Directory**. It creates or replaces a local CSV file at the specified destination.

## Validation performed

Tested against the home-lab users `alex.morgan` and `jamie.reed`, including Jamie's `Sales` department and `GG_Sales` security group membership. Verified normal CSV output and error handling with an invalid OU and an invalid output directory.

## Related lab documentation

See [Environment / infrastructure](../../architecture/environment.md) for the Windows domain, virtual machines and network design.
