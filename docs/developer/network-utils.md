# Network Utilities

## Overview

The `network-utils.sh` library provides common network discovery and diagnostic functions used across Citadel modules.

## Location

```
lib/network-utils.sh
```

## Functions

### Interface Discovery

```bash
discover_active_interface()
```
Returns the name of the active network interface (e.g., `eth0`, `wlan0`).

**Usage:**
```bash
source "${CYTADELA_LIB}/network-utils.sh"
IFACE=$(discover_active_interface)
echo "Active interface: $IFACE"
```

### Network Stack Detection

```bash
discover_network_stack()
```
Detects the network configuration type:
- `NetworkManager` - Using NetworkManager
- `systemd-networkd` - Using systemd-networkd
- `dhcpcd` - Using dhcpcd
- `manual` - Manual configuration

**Usage:**
```bash
STACK=$(discover_network_stack)
echo "Network stack: $STACK"
```

### IP Address Functions

```bash
get_primary_ip()
```
Returns the primary IPv4 address of the system.

```bash
get_primary_ipv6()
```
Returns the primary IPv6 address (if available).

### Gateway Detection

```bash
discover_gateway()
```
Returns the default gateway IP address.

## Dependencies

- `ip` (iproute2 package)
- `route` (net-tools package, fallback)
- `nmcli` (NetworkManager, optional)

## Error Handling

All functions return empty string on failure. Check with:
```bash
IFACE=$(discover_active_interface)
if [[ -z "$IFACE" ]]; then
    log_error "No active interface found"
    exit 1
fi
```

## Integration

Used by:
- `modules/discover.sh` - Network discovery
- `modules/ipv6.sh` - IPv6 configuration
- `modules/ghost-check.sh` - Port exposure audit
