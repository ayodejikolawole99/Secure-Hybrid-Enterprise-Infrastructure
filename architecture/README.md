**ARCHITECTURE OVERVIEW**

_This project implements a secure, scalable enterprise network architecture based on a hierarchical core-distribution-access model, with explicit segmentations for users, admins, servers, guests, and public-facing services._

The design prioritizes:
- Clear separation of trust zones
- Centralized routing and policy enforcement
- Realistic enterprise security controls
- Extensibility for cloud and hybrid environments

This architecture was first modeled in Cisco Packet Tracer to validate Layer 2 and Layer 3 behavior, then designed to be portable to cloud infrastructure (Azure) in later phases.


**High-Level Design**

At a high level, the network follows this flow:

Internet -> Edge Router -> Firewall -> Core Switch -> Distribution Layer -> Access Layer

A dedicated DMZ is terminated directly on the firewall to isolate public-facing services from internal networks.



**Network Layers and Roles**

**1. Internet Edge**
   
The internet edge simulates an upstream ISP connection and provides external connectivity to the enterprise.

- Edge Router
    - Acts as the WAN handoff device
    - Maintains a default route toward the ISP
    - Forwards traffic to the firewall
    - Does not perform internal security filtering
 
  This separation ensures that all security decisions are enforced at the firewall layer



**2. Perimeter Security (Firewall)**

A stateful firewall sits between the public network and the internal enterprise environment.

Firewall responsibilities include:

- Network Address Translation (NAT) for internal networks
- Enforcement of north-south traffic policies
- Segmentation between inside, outside, and DMZ zones
- Controlled exposure of public services

  The firewall defines three security zones:

   - Outside - Untrusted internet
   - Inside - Internal enterprise networks
   - DMZ - Public facing services


     
**3.  Core Layer (Layer 2 Switching)**

This core switch functions as the central routing point for all internal VLANs.

Key characteristics:

- Performs inter-VLAN routing using SVIs
- Acts as the default gateway for internal networks
- Maintains a default route pointing to the firewall
- Does not directly connect to end devices

  This approach centralizes routing logic while keeping access-layer switches simple and scalable.


 
**4. Distribution Layer**

The distribution layer aggregates access switches and enforces logical segmentation between different functional areas of the network.

Two distribution switches are used:

- Distribution Switch 1 - Users and Internal Servers

Handles business-critical internal traffic:
  - User access networks
  - Internal application and infrastructure servers
  This separation ensures that server traffic can be more tightly controlled and monitored.

- Distribution Switch 2 - Admin, Security, and Guest Networks

Handles higher risk and admin traffic:

- IT/Admin workstations
- Security and monitoring tools
- Guest user access

Guest traffic is intentionally kept separate from internal user and server networks.


**5. Access Layer**

Access switches provide physical connectivity for end devices.

Each access switch services a single functional VLAN:

  - User devices
  - Admin workstations
  - Internal serves
  - Security tools
  - Guest devices

Ports are configures as access ports with appropriate VALN assignments, and edge features such as PortFast are enabled where applicable.

**VLAN and Network Segmentation**

The network is segmented using VLANs to enforce separation of duties and security boundaries:

VLAN         	                        Purpose                                                                     	Description

VLAN 10                             	Users   	                                                                    Standard enterprise user endpoints

VLAN 20                             	IT / Admin                                                              	    Administrative and privileged access

VLAN 30                             	Internal Servers                                                             	Application, directory, and file servers
                                                                   
VLAN 40                             	Security                                                                    	Monitoring, logging and security tools

VLAN 50                             	Guests	                                                                      Internet only guest access

VLAN 60                             	DMZ                                                                         	Public facing services


Inter-VLAN routing is performed only at the core, while traffic to and from the internet is strictly controlled by the firewall.


**Server Placement Strategy**

**Internal Servers (VLAN 30)**

Internal servers are connected through the distribution and access layers and use the core switch as their default gateway.

Examples include:
-	Directory services
-	Internal applications
-	Databases
-	File and backup servers
  
These servers are protected from direct internet access and are reachable only through controlled internal routes.


**DMZ Servers (VLAN 60)**

Public facing servers are placed in a dedicated DMZ.
-	Connected directly to the firewall
-	Not routed through the core
-	Subject to strict firewall policies
  
Typical services include:

-	 Public web servers
-	Reverse proxies
-	Public APIs


This deign minimizes the blast radius of a potential compromise.



**Security Design Principles**

The architecture enforces several key security principles:

-	Least privilege: Guest and user networks have no direct access to sensitive internal resources
-	Defense in depth: Multiple layers of segmentation (VLANs, firewall zones)
-	Reduced lateral movement: DMZ traffic is isolated from internal routing
-	Centralized policy enforcement: Firewall and core act as control points


**Scalability and Cloud Readiness**

The architecture is intentionally modular:

-	Additional VLANs can be added without redesigning the network
-	Distribution and access layers can scale horizontally
-	The design maps cleanly to cloud constructs such as:
  -  Azure Virtual Networks
  -   Network Security Groups
  -   Hub-and-spoke topologies
    
This makes the environment suitable for hybrid or full cloud migration scenarios.

**Summary**

_This architecture demonstrates a realistic enterprise infrastructure design that balances security, scalability, and operational clarity.
It reflects real-world constraints encountered in production environments, including VLAN propagation, trunking consistency, firewall zoning, and fault domain isolation._



