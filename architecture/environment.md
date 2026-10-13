# IT Support Home Lab — Environment

## 1. Project Overview

This home lab is designed to develop practical skills in Windows administration, networking, troubleshooting, PowerShell, and Microsoft infrastructure.

The environment uses Oracle VirtualBox to simulate a small business IT environment, with a Windows Server machine and a Windows 11 client workstation.

## 2. Host System

| Component | Specification |
| --- | --- |
| Operating System | Windows 11 Home |
| Processor | AMD Ryzen 7 7800X3D |
| Memory | 32 GB DDR5 |
| Storage | 2 TB NVMe SSD |
| Hypervisor | Oracle VirtualBox |

## 3. Virtual Machines

### DC01 — Windows Server

| Property | Configuration |
| --- | --- |
| Operating System | Windows Server 2025 Standard Evaluation |
| Virtual CPUs | 4 |
| RAM | 6 GB |
| Storage | 80 GB (dynamically allocated) |
| Adapter 1 | VirtualBox NAT |
| Adapter 2 | Internal Network (`IT-LAB`) |

**Purpose:**

DC01 will eventually provide centralised network administration through Active Directory Domain Services (AD DS), DNS, and DHCP.

**Current status:** Windows installed and updated; VirtualBox Guest Additions configured. Network connectivity verified. DC01 is not yet an Active Directory domain controller, and AD DS, DNS Server, and DHCP Server roles have not been deployed.

### CLIENT01 — Windows Workstation

| Property | Configuration |
| --- | --- |
| Operating System | Windows 11 Enterprise Evaluation |
| Virtual CPUs | 4 |
| RAM | 8 GB |
| Storage | 100 GB (dynamically allocated) |
| Adapter 1 | VirtualBox NAT |
| Adapter 2 | Internal Network (`IT-LAB`) |

**Purpose:**

CLIENT01 simulates an employee workstation for practising Windows administration, network connectivity, troubleshooting, PowerShell, and eventual Active Directory domain integration.

**Current status:** Windows installed and updated; VirtualBox Guest Additions configured. Initial PowerShell and networking exercises completed, including a resolved DNS client troubleshooting incident.

## 4. Network Architecture

### Current Configuration

Each virtual machine has two network adapters:

- **Adapter 1 — NAT:** Provides outbound internet access. IPv4 addressing, default gateway, and DNS settings are normally supplied automatically through VirtualBox NAT/DHCP.
- **Adapter 2 — Internal Network (`IT-LAB`):** Connects DC01 and CLIENT01 on a private virtual network, separate from the physical home LAN. Its IPv4 address is configured manually, without a default gateway or DNS server.

This arrangement allows the VMs to communicate with one another while keeping future internal DNS, DHCP, and domain-service experiments separate from the home network.

### IP Configuration

| Machine | Adapter | IPv4 configuration | Default gateway | DNS |
| --- | --- | --- | --- | --- |
| DC01 | NAT | DHCP (observed `10.0.2.15`) | `10.0.2.2` | Automatically supplied |
| DC01 | `IT-LAB` | `10.10.10.10/24` (static) | None | None |
| CLIENT01 | NAT | DHCP (observed `10.0.2.15`) | `10.0.2.2` | Automatically supplied |
| CLIENT01 | `IT-LAB` | `10.10.10.20/24` (static) | None | None |

**Internal network:** `10.10.10.0/24` (subnet mask `255.255.255.0`). Both VMs use the same VirtualBox Internal Network name: `IT-LAB`.

The NAT interfaces can have the same observed IP address because VirtualBox provides each VM with a separate NAT environment. The internal `IT-LAB` addresses must be unique.

### Connectivity and Recovery

- Verified communication between DC01 and CLIENT01 over `IT-LAB` in both directions.
- Added narrowly scoped Windows Firewall rules permitting inbound ICMPv4 echo requests on the lab network; Windows Firewall remains enabled.
- Verified outbound connectivity and DNS resolution through the NAT adapters.
- Inspected IPv4 adapter and routing information, and saved network baseline evidence on both VMs under `C:\LabEvidence`.
- Created VirtualBox snapshots of the working network configuration in addition to the earlier clean-install snapshots.

## 5. Current Progress and Next Steps

**Completed:**

- Installed and updated both virtual machines and configured VirtualBox Guest Additions.
- Created clean-install and working-network snapshots.
- Configured NAT and isolated `IT-LAB` adapters on both VMs.
- Assigned static IPv4 addresses and verified VM-to-VM and internet connectivity.
- Practised Windows service inspection and introductory PowerShell administration.
- Diagnosed and resolved an intentional DNS client configuration failure on CLIENT01; normal DNS resolution was verified after repair.

**Planned:**

- Deploy Active Directory Domain Services, DNS Server, and DHCP Server roles.
- Join CLIENT01 to the domain.
- Practise users, groups, Group Policy, and file/share permissions.
- Continue Windows and PowerShell administration exercises and document meaningful troubleshooting incidents.

This document will be updated as the environment develops.
