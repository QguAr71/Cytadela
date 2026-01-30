#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Diagnostics Strings (EN)                                    ║
# ║  Translations for diagnostics and verify commands                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Verify command
export DIAG_VERIFY_TITLE="CITADEL++ VERIFY"
export DIAG_VERIFY_PORTS="Ports:"
export DIAG_VERIFY_SERVICES="Services:"
export DIAG_VERIFY_FIREWALL="Firewall:"
export DIAG_VERIFY_DNS_TESTS="DNS tests:"
export DIAG_VERIFY_METRICS="Metrics:"
export DIAG_VERIFY_LEAK_TEST="Leak test (STRICT expected to block):"
export DIAG_VERIFY_IPV6_TEST="IPv6 test:"

# Port status
export DIAG_PORT_DNSCRYPT="DNSCrypt listen"
export DIAG_PORT_COREDNS="CoreDNS listen"
export DIAG_PORT_METRICS="Metrics"

# Service status
export DIAG_SVC_RUNNING="running"
export DIAG_SVC_STOPPED="stopped"
export DIAG_SVC_FAILED="failed"

# Firewall status
export DIAG_FW_LOADED="nftables rules: loaded"
export DIAG_FW_NOT_LOADED="nftables rules: not loaded"
export DIAG_FW_MODE="Mode"
export DIAG_FW_SAFE="SAFE"
export DIAG_FW_STRICT="STRICT"

# DNS tests
export DIAG_DNS_OK="Local DNS OK"
export DIAG_DNS_FAILED="Local DNS FAILED"
export DIAG_DNS_TIMEOUT="DNS timeout"

# Metrics
export DIAG_METRICS_OK="Prometheus endpoint OK"
export DIAG_METRICS_FAILED="Prometheus endpoint FAILED"

# Leak test
export DIAG_LEAK_BLOCKED="Leak test: blocked (good)"
export DIAG_LEAK_NOT_BLOCKED="Leak test: NOT blocked (dig @1.1.1.1 succeeded)"

# IPv6 test
export DIAG_IPV6_OK="IPv6 connectivity OK"
export DIAG_IPV6_FAILED="IPv6 connectivity FAILED"

# Status command
export DIAG_STATUS_TITLE="CITADEL++ STATUS"
export DIAG_STATUS_DNS="DNS Resolution"
export DIAG_STATUS_WORKING="working"
export DIAG_STATUS_NOT_WORKING="NOT WORKING"
