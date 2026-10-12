# IT Support Home Lab — Environment

## 1. Project Overview

This home lab is designed to develop practical skills in Windows administration, networking, troubleshooting, PowerShell, and Microsoft infrastructure.

The environment uses Oracle VirtualBox to simulate a small business IT environment, with a Windows Server machine and a Windows 11 client workstation.

## 2. Host System

| Component        | Specification       |
| ---------------- | ------------------- |
| Operating System | Windows 11 Home     |
| Processor        | AMD Ryzen 7 7800X3D |
| Memory           | 32 GB DDR5          |
| Storage          | 2 TB NVMe SSD       |
| Hypervisor       | Oracle VirtualBox   |

## 3. Virtual Machines

### DC01 — Windows Server

| Property         | Configuration                           |
| ---------------- | --------------------------------------- |
| Operating System | Windows Server 2025 Standard Evaluation |
| Virtual CPUs     | 4                                       |
| RAM              | 6 GB                                    |
| Storage          | 80 GB (dynamically allocated)           |
| Networking       | VirtualBox NAT (current)                |

**Purpose:**

DC01 will eventually provide centralised network administration through Active Directory Domain Services, DNS, and DHCP.

**Current status:** Windows installed and updated. Guest Additions configured. Server roles have not yet been deployed.

### CLIENT01 — Windows Workstation

| Property         | Configuration                    |
| ---------------- | -------------------------------- |
| Operating System | Windows 11 Enterprise Evaluation |
| Virtual CPUs     | 4                                |
| RAM              | 8 GB                             |
| Storage          | 100 GB (dynamically allocated)   |
| Networking       | VirtualBox NAT (current)         |

**Purpose:**

CLIENT01 simulates an employee workstation for practising Windows administration, network connectivity, troubleshooting, PowerShell, and eventual Active Directory domain integration.

**Current status:** Windows installed and updated. Guest Additions configured. Initial PowerShell and network inspection exercises completed.

## 4. Network Architecture

### Current Configuration

Both virtual machines use VirtualBox NAT networking to provide internet connectivity.

The dedicated internal lab network has not yet been configured.

### Planned Configuration

| Component   | Planned Address |
| ----------- | --------------- |
| Lab network | 10.10.10.0/24   |
| DC01        | 10.10.10.10     |
| CLIENT01    | 10.10.10.20     |

The planned `IT-LAB` network will support communication between the virtual machines for future networking and Windows Server exercises.

These addresses are **planned, not currently assigned**.

## 5. Current Progress and Next Steps

**Completed:**

- Installed and updated both virtual machines.
- Configured VirtualBox Guest Additions.
- Verified initial internet connectivity.
- Created clean installation snapshots.
- Began Windows and PowerShell administration exercises.

**Planned:**

- Configure the dedicated IT-LAB network.
- Deploy Active Directory Domain Services, DNS, and DHCP.
- Join CLIENT01 to the domain.
- Practise user, group, and permissions management.
- Simulate and document troubleshooting incidents.

This document will be updated as the environment develops.


