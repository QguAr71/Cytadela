# Narzędzia Sieciowe

## Przegląd

Biblioteka `network-utils.sh` udostępnia wspólne funkcje odkrywania sieci i diagnostyki używane w całym systemie modułów Cytadela.

## Lokalizacja

```
lib/network-utils.sh
```

## Funkcje

### Odkrywanie Interfejsów

```bash
discover_active_interface()
```
Zwraca nazwę aktywnego interfejsu sieciowego (np. `eth0`, `wlan0`).

**Użycie:**
```bash
source "${CYTADELA_LIB}/network-utils.sh"
IFACE=$(discover_active_interface)
echo "Aktywny interfejs: $IFACE"
```

### Wykrywanie Stosu Sieciowego

```bash
discover_network_stack()
```
Wykrywa typ konfiguracji sieciowej:
- `NetworkManager` - Używając NetworkManager
- `systemd-networkd` - Używając systemd-networkd
- `dhcpcd` - Używając dhcpcd
- `manual` - Konfiguracja manualna

**Użycie:**
```bash
STACK=$(discover_network_stack)
echo "Stos sieciowy: $STACK"
```

### Funkcje Adresów IP

```bash
get_primary_ip()
```
Zwraca główny adres IPv4 systemu.

```bash
get_primary_ipv6()
```
Zwraca główny adres IPv6 (jeśli dostępny).

### Wykrywanie Bramy

```bash
discover_gateway()
```
Zwraca adres IP domyślnej bramy.

## Zależności

- `ip` (pakiet iproute2)
- `route` (pakiet net-tools, fallback)
- `nmcli` (NetworkManager, opcjonalny)

## Obsługa Błędów

Wszystkie funkcje zwracają pusty string przy niepowodzeniu. Sprawdź z:
```bash
IFACE=$(discover_active_interface)
if [[ -z "$IFACE" ]]; then
    log_error "Nie znaleziono aktywnego interfejsu"
    exit 1
fi
```

## Integracja

Używane przez:
- `modules/discover.sh` - Odkrywanie sieci
- `modules/ipv6.sh` - Konfiguracja IPv6
- `modules/ghost-check.sh` - Audyt ekspozycji portów
