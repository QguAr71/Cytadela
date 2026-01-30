#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Stringi Diagnostyczne (PL)                                  ║
# ║  Tłumaczenia dla komend diagnostycznych i verify                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Komenda verify
export DIAG_VERIFY_TITLE="WERYFIKACJA CITADEL++"
export DIAG_VERIFY_PORTS="Porty:"
export DIAG_VERIFY_SERVICES="Usługi:"
export DIAG_VERIFY_FIREWALL="Firewall:"
export DIAG_VERIFY_DNS_TESTS="Testy DNS:"
export DIAG_VERIFY_METRICS="Metryki:"
export DIAG_VERIFY_LEAK_TEST="Test wycieku (STRICT powinien blokować):"
export DIAG_VERIFY_IPV6_TEST="Test IPv6:"

# Status portów
export DIAG_PORT_DNSCRYPT="Nasłuch DNSCrypt"
export DIAG_PORT_COREDNS="Nasłuch CoreDNS"
export DIAG_PORT_METRICS="Metryki"

# Status usług
export DIAG_SVC_RUNNING="uruchomiony"
export DIAG_SVC_STOPPED="zatrzymany"
export DIAG_SVC_FAILED="błąd"

# Status firewall
export DIAG_FW_LOADED="reguły nftables: załadowane"
export DIAG_FW_NOT_LOADED="reguły nftables: nie załadowane"
export DIAG_FW_MODE="Tryb"
export DIAG_FW_SAFE="BEZPIECZNY"
export DIAG_FW_STRICT="ŚCISŁY"

# Testy DNS
export DIAG_DNS_OK="Lokalny DNS OK"
export DIAG_DNS_FAILED="Lokalny DNS NIEPOWODZENIE"
export DIAG_DNS_TIMEOUT="Przekroczono limit czasu DNS"

# Metryki
export DIAG_METRICS_OK="Endpoint Prometheus OK"
export DIAG_METRICS_FAILED="Endpoint Prometheus NIEPOWODZENIE"

# Test wycieku
export DIAG_LEAK_BLOCKED="Test wycieku: zablokowany (dobrze)"
export DIAG_LEAK_NOT_BLOCKED="Test wycieku: NIE zablokowany (dig @1.1.1.1 zadziałał)"

# Test IPv6
export DIAG_IPV6_OK="Łączność IPv6 OK"
export DIAG_IPV6_FAILED="Łączność IPv6 NIEPOWODZENIE"

# Komenda status
export DIAG_STATUS_TITLE="STATUS CITADEL++"
export DIAG_STATUS_DNS="Rozwiązywanie DNS"
export DIAG_STATUS_WORKING="działa"
export DIAG_STATUS_NOT_WORKING="NIE DZIAŁA"
