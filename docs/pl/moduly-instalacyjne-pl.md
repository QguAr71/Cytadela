# Moduły Instalacyjne

## Przegląd

Cytadela używa osobnych modułów instalacyjnych dla każdego komponentu:
- `install-dnscrypt.sh` - Szyfrowanie DNS
- `install-coredns.sh` - Serwer DNS z adblock
- `install-nftables.sh` - Reguły firewall

## Wspólny Przepływ Instalacji

Każdy instalator przestrzega tego samego wzorca:
1. Sprawdź wymagania wstępne
2. Zainstaluj pakiet
3. Wygeneruj konfigurację
4. Włącz i uruchom usługę
5. Zweryfikuj instalację

## install-dnscrypt.sh

### Cel
Instaluje i konfiguruje DNSCrypt-Proxy dla zaszyfrowanych zapytań DNS.

### Konfiguracja
- **Port**: 127.0.0.1:5355
- **Protokoły**: DoH, DoT, DNSCrypt
- **Serwery**: cloudflare, google, quad9

### Wygenerowane Pliki
- `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- `/etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf`

## install-coredns.sh

### Cel
Instaluje CoreDNS z możliwościami cache i adblock.

### Konfiguracja
- **Port**: 127.0.0.1:53
- **Funkcje**: Cache, adblock, metryki Prometheus
- **Upstream**: 127.0.0.1:5355 (DNSCrypt)

### Wygenerowane Pliki
- `/etc/coredns/Corefile`
- `/etc/coredns/zones/blocklist.hosts`
- Pobieranie i przetwarzanie blocklist

### Źródła Blocklist
- StevenBlack hosts
- OISD blocklist
- Niestandardowe listy użytkownika

## install-nftables.sh

### Cel
Konfiguruje NFTables firewall dla ochrony przed wyciekami DNS.

### Reguły
- Zezwól na lokalny DNS (53, 5355)
- Blokuj zewnętrzne zapytania DNS
- Włącz liczniki do monitorowania

### Wygenerowane Pliki
- `/etc/nftables.conf`
- Reguły runtime w tabeli `inet citadel_dns`

## Weryfikacja

Każdy instalator uruchamia sprawdzenia po instalacji:
```bash
# Sprawdź status usługi
systemctl is-active [usługa]

# Test rozwiązywania DNS
dig +short google.com @127.0.0.1

# Zweryfikuj firewall
nft list table inet citadel_dns
```

## Rollback

Wszystkie instalatory tworzą backup przed zmianami:
```bash
# Lokalizacja backup
/etc/cytadela/backups/

# Przywróć
sudo ./citadel.sh restore-system
```
