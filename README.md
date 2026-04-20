# Secure-Hybrid-Enterprise-Infrastructure
A zero trust, compliance driven hybrid enterprise network project. This project aims to show ones understanding of the following:

1. Enterprise network architecture
2. Hybrid cloud (On-prem and Azure)
3. Identity and Access management (IAM)
4. Zero trust security
5. Data privacy and compliance
6. SOC / SIEM integration
7. Business continuity
8. Real world IT operations


# Fictional Enterprise Scenario

Using a fictional company to anchor everything.

**Company:** Aurum Manufacturing Group (AMG)

**Industry:** Manufacturing and Logistics

**Size:** 500 - 800 employees

**Locations:**

- HQ (On-Prem Domain Controller)
- Branch offices (2)
- Remote workforce
- Azure cloud

**Regulatory drivers:**

- GDPR/NDPR
- Internal audit and logging
- Least privilege access
- Incident response readiness

# HIGH-LEVEL ARCHITECTURE

This project has 6 major pillars 

**1. ENTERPRISE NETWORK DESIGN (Cisco Packet Tracer)**

A 3-tier enterprise network:

- Network Zones
- Core Layer
- Distribution Layer
- Access Layer


**Segmentation (VLANs)**

- VLAN 10 – Corporate Users
- VLAN 20 – IT/Admin
- VLAN 30 – Servers
- VLAN 40 – Security Tools
- VLAN 50 – Guest
- VLAN 60 – DMZ
  
**Network Security**

- ACLs between VLANs
- Inter-VLAN routing

**DMZ segment:**

- Web server
- VPN gateway
- Site-to-Site VPN (conceptual in PT)
  
**Devices**

- Core Switch
- Distribution Switches
- Access Switches
- Edge Router
- Firewall (simulated)
- Servers
- User devices

**2. IDENTITY & ACCESS MANAGEMENT (On-Prem + Azure)**

**On-Prem IAM**

**Active Directory Domain:**

corp.nmg.local

**OUs:**

- Users
- IT Admins
- Servers
- Workstations

**Group Policies:**

- Password policy
- Device hardening
- USB restrictions
- Role-Based Access Control (RBAC)

**Hybrid Identity**

- Azure AD Connect (conceptual + Azure setup)
- Sync users to Azure Entra ID
- Conditional Access:
- MFA for admins
- Geo-blocking
- Device compliance

**3. AZURE CLOUD ARCHITECTURE**

**Azure Components**

- Azure Virtual Network (VNet)
- Subnets:
  - Management
  - Application
  - Security
-NSGs enforcing Zero Trust

**Azure VMs:**

- Domain Controller
- Application Server
- Log Server
- Azure Bastion (optional)
- Azure Storage Account (data classification)
  
**Connectivity**

- Site-to-Site VPN (design + partial implementation)
- Private endpoints
- No public RDP

**4. SECURITY OPERATIONS (SOC / SIEM)**

Directly tied to your SOC experience.

**Logging & Monitoring:**

Azure Sentinel (Log Analytics)

**Data sources:**

- Azure AD sign-ins
- VM security logs
- Firewall logs (simulated)

**Detection rules:**

- Impossible travel
- Brute force
- Privilege escalation

**Incident Response**

**Incident lifecycle:**

- Detect
- Investigate
- Contain
- Recover
- Sample incident report

**5. DATA PRIVACY & COMPLIANCE (DPCO Layer)**

**Data Classification**

- Public
- Internal
- Confidential
- Restricted
  
**Privacy Controls**

- Data flow mapping
- Access logging
- Retention policies
- Encryption at rest & in transit

**Compliance Alignment**

- GDPR principles
- DPIA (mock)
- DSAR handling flow
- Audit trail design

**6. BUSINESS CONTINUITY & DR**

**Resilience:**

- Backup strategy
- VM snapshots
- Azure Recovery Services Vault
- RTO / RPO definitions

**Scenarios:**

- Ransomware
- Data loss
- Identity compromise
