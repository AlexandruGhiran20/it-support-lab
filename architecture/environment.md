# IT Support Home Lab — Environment

## 1. Project Overview

This home lab develops practical skills in Windows administration, networking, troubleshooting, PowerShell, and Microsoft infrastructure.

Oracle VirtualBox hosts a small, isolated Windows domain environment consisting of a Windows Server domain controller and a Windows 11 workstation. The lab is separate from the physical home LAN, while both VMs retain outbound internet connectivity.

**Active Directory domain:** `corp.itlab.test` (NetBIOS: `CORP`).

## 2. Host System

| Component | Specification |
| --- | --- |
| Operating System | Windows 11 Home |
| Processor | AMD Ryzen 7 7800X3D |
| Memory | 32 GB DDR5 |
| Storage | 2 TB NVMe SSD |
| Hypervisor | Oracle VirtualBox |

## 3. Virtual Machines

### DC01 — Domain Controller and DNS Server

| Property | Configuration |
| --- | --- |
| Operating System | Windows Server 2025 Standard Evaluation |
| Virtual CPUs | 4 |
| RAM | 6 GB |
| Storage | 80 GB (dynamically allocated) |
| Adapter 1 | VirtualBox NAT |
| Adapter 2 | Internal Network (`IT-LAB`) |
| Internal IPv4 | `10.10.10.10/24` |
| Domain roles | Active Directory Domain Services; DNS Server |

**Purpose:** Provides centralised identity management, domain authentication, and internal DNS for the lab.

**Current status:** Promoted as the first domain controller in the `corp.itlab.test` forest. AD DS and DNS services are operational; internal hostname resolution, LDAP SRV records, and external DNS lookups through DC01 have been tested. **DHCP Server has not been installed.**

### CLIENT01 — Domain-Joined Workstation

| Property | Configuration |
| --- | --- |
| Operating System | Windows 11 Enterprise Evaluation |
| Virtual CPUs | 4 |
| RAM | 8 GB |
| Storage | 100 GB (dynamically allocated) |
| Adapter 1 | VirtualBox NAT |
| Adapter 2 | Internal Network (`IT-LAB`) |
| Internal IPv4 | `10.10.10.20/24` |
| Domain membership | `corp.itlab.test` |

**Purpose:** Simulates an employee workstation for Windows support, domain authentication, troubleshooting, administration, and later Group Policy and permissions exercises.

**Current status:** Successfully domain-joined. Domain membership and secure channel checks passed. The standard domain user `CORP\alex.morgan` successfully signed in and changed an initial temporary password.

## 4. Network Architecture

### Current Configuration

Each VM has two adapters:

- **Adapter 1 — NAT (`Ethernet`):** Receives an IPv4 address and default gateway through VirtualBox DHCP and provides outbound internet connectivity.
- **Adapter 2 — Internal Network (`Ethernet 2` / `IT-LAB`):** Uses a static IPv4 address to carry direct traffic between DC01 and CLIENT01. No default gateway is configured on this adapter.

`IT-LAB` is an isolated VirtualBox Internal Network, not a bridged connection to the home LAN. Internal directory and DNS services therefore remain confined to the lab.

### IP and DNS Configuration

| Machine | Adapter | IPv4 configuration | Default gateway | Configured DNS server |
| --- | --- | --- | --- | --- |
| DC01 | NAT | DHCP (observed `10.0.2.15`) | `10.0.2.2` | `10.10.10.10` |
| DC01 | `IT-LAB` | `10.10.10.10/24` (static) | None | `10.10.10.10` |
| CLIENT01 | NAT | DHCP (observed `10.0.2.15`) | `10.0.2.2` | `10.10.10.10` |
| CLIENT01 | `IT-LAB` | `10.10.10.20/24` (static) | None | `10.10.10.10` |

**Internal subnet:** `10.10.10.0/24` (`255.255.255.0`). The NAT adapters may show the same IPv4 address because each VM has its own VirtualBox NAT environment.

After AD DS promotion, **DNS server addresses were explicitly configured** on both adapters of each VM to use DC01 (`10.10.10.10`). DHCP still supplies the NAT adapter IP addresses and default gateways; it no longer determines the configured DNS server addresses.

### Active Directory and DNS

- **Domain/forest:** `corp.itlab.test` (`CORP`).
- **Domain controller:** `DC01.corp.itlab.test` at `10.10.10.10` on `IT-LAB`.
- **DNS:** DC01 hosts the internal domain's DNS zone and answers external queries through upstream resolution.
- **DNS Server listener:** Restricted to `10.10.10.10` rather than the VirtualBox NAT address.
- **Adapter DNS registration:** Disabled for DC01's NAT adapter and enabled for its `IT-LAB` adapter.
- **Verification:** The stored `DC01` A record and direct DNS-only queries return `10.10.10.10`; AD's LDAP SRV lookup also succeeds. CLIENT01 can resolve internal and external names and locate the domain controller.

**Open observation:** On DC01, an ordinary `Resolve-DnsName dc01.corp.itlab.test -Type A -Server 10.10.10.10` also displayed `10.0.2.15`, even after clearing the DNS client cache. However, the zone record inspection, `nslookup` and a `Resolve-DnsName` query with `-DnsOnly -NoHostsFile` returned only `10.10.10.10`. The extra result's origin has not been established; no related domain-join or authentication failure was observed. Further investigation is deferred unless it causes problems.

### Active Directory Accounts and Groups

- **`Lab Users` OU:** Contains the standard test accounts `alex.morgan` (Alex Morgan) and `jamie.reed` (Jamie Reed).
- **`Lab Groups` OU:** Contains the global security group `GG_Sales`. Jamie is a member of `GG_Sales`; the `Department` attribute on Jamie's account is `Sales`.
- **Administration exercises:** Created users and OUs, managed security group membership, reset a user password, disabled/re-enabled Jamie's account, and verified account state and group membership through Active Directory PowerShell cmdlets.
- **Permissions:** No file shares or resource permissions have yet been assigned to `GG_Sales`. Group membership is verified, but resource-access control has not been tested.

### Connectivity, Troubleshooting, and Recovery

- Verified VM-to-VM connectivity over `IT-LAB`, using narrowly scoped inbound ICMPv4 firewall rules. Windows Firewall remains enabled.
- Verified external IP connectivity and DNS resolution from both VMs.
- Verified CLIENT01 domain membership (`PartOfDomain = True`), secure channel (`True`), and running Netlogon service.
- Created an OU called `Lab Users` and a standard user `alex.morgan`; domain authentication on CLIENT01 succeeded.
- Preserved original network baseline evidence under `C:\LabEvidence` on both VMs.
- Created clean-install, working-network, and post-domain-configuration VirtualBox snapshots for both machines.

**Stability observation:** CLIENT01 froze twice during/after domain joining, requiring VirtualBox power-off recovery. Afterward, the VM ran normally under observation, resolved external names, and restarted successfully. No clear cause appeared in brief Task Manager/Event Viewer checks. Host RAM usage was observed near 90% while both VMs were running (14 GB total guest allocation). Resource pressure is a possible contributing factor, **not a confirmed root cause**. If freezes recur, inspect guest/host memory use, paging, and VirtualBox logs before changing allocations.

VirtualBox snapshots are recovery checkpoints, not substitutes for proper domain controller/system-state backups. Avoid independently rolling back DC01 and CLIENT01 during normal administration exercises.

## 5. Current Progress and Next Steps

**Completed:**

- Installed and updated both VMs; configured VirtualBox Guest Additions.
- Set up NAT plus the isolated `IT-LAB` network; assigned static internal IPv4 addresses.
- Verified connectivity and saved initial network baselines and snapshots.
- Practised introductory Windows, networking and PowerShell administration.
- Investigated, fixed and documented Incident 001: incorrect DNS client configuration on CLIENT01.
- Installed AD DS and DNS Server, created `corp.itlab.test`, and promoted DC01.
- Verified internal DNS A/SRV lookups and external resolution.
- Joined CLIENT01 to the domain and verified its secure channel.
- Created the `Lab Users` and `Lab Groups` OUs, two standard user accounts, and `GG_Sales`; verified domain sign-in and group membership.
- Practised Active Directory user/group administration and the account lifecycle using ADUC and PowerShell.
- Built and tested the read-only [Active Directory Account Audit Tool](../powershell/ADAccountAudit/README.md), which retrieves users, account status, departments and direct security group memberships, and exports a CSV report.
- Captured post-domain-configuration VirtualBox snapshots of both VMs.

**Planned:**

- Introduce Group Policy and Windows file/share permissions, including a practical group-based access test.
- Configure DHCP Server in a separate, controlled exercise.
- Continue developing PowerShell administration skills through focused scripts and practical troubleshooting.
- Investigate a real laptop Wi-Fi issue as a separate hands-on troubleshooting exercise.
- Investigate CLIENT01 stability further only if the freezing recurs; continue documenting meaningful support incidents.

This document will be updated as the environment develops.
