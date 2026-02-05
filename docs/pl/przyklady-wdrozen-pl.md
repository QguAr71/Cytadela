# 📦 Przykłady Wdrożeń

Ten przewodnik zawiera rzeczywiste scenariusze wdrażania dla Cytadela.

---

## 📋 Spis Treści

1. [Konfiguracja Użytkownika Domowego](#-konfiguracja-użytkownika-domowego)
2. [Konfiguracja Małego Biura](#️-konfiguracja-małego-biura)
3. [Konfiguracja Trybu Gateway](#-konfiguracja-trybu-gateway)
4. [Konfiguracja Raspberry Pi](#-konfiguracja-raspberry-pi)
5. [Konfiguracja Multi-Urządzenia](#️-konfiguracja-multi-urządzenia)

---

## 🏠 Konfiguracja Użytkownika Domowego

**Scenariusz:** Pojedynczy użytkownik, osobisty laptop/desktop, podstawowe potrzeby prywatności.

### Wymagania

- 1 maszyna Linux (Arch/CachyOS)
- 2 GB RAM minimum
- Aktywne połączenie internetowe

### Instalacja

```bash
# 1. Klonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# 2. Uruchom interaktywny instalator
sudo ./citadel.sh install-wizard

# 3. Wybierz komponenty (zalecane):
#    [x] DNSCrypt-Proxy
#    [x] CoreDNS
#    [x] NFTables
#    [x] Blokowanie reklam (profil balanced)
#    [ ] Terminal Dashboard (opcjonalne)

# 4. Skonfiguruj system
sudo ./citadel.sh configure-system

# 5. Włącz firewall
sudo ./citadel.sh firewall-safe

# 6. Zweryfikuj instalację
sudo ./citadel.sh verify
```

### Konfiguracja

```bash
# Włącz auto-aktualizacje
sudo ./citadel.sh auto-update-enable

# Skonfiguruj backup
sudo ./citadel.sh config-backup

# Włącz prywatność IPv6
sudo ./citadel.sh ipv6-privacy-auto
```

### Codzienne Użycie

```bash
# Sprawdź status
sudo ./citadel.sh status

# Wyświetl statystyki
sudo ./citadel.sh cache-stats
sudo ./citadel.sh adblock-stats

# Aktualizuj listy blokowania
sudo ./citadel.sh adblock-update
```

### Konserwacja

```bash
# Co tydzień: Sprawdź aktualizacje
sudo ./citadel.sh auto-update-status

# Co miesiąc: Backup konfiguracji
sudo ./citadel.sh config-backup

# W razie potrzeby: Wyświetl logi
sudo ./citadel.sh logs
```

---

## 👨‍💼 Konfiguracja Małego Biura

**Scenariusz:** 5-10 użytkowników, współdzielona sieć, potrzeby prywatności biznesowej.

### Wymagania

- 1 serwer Linux (dedykowany lub VM)
- 4 GB RAM minimum
- Statyczny adres IP
- Dostęp sieciowy dla wszystkich klientów

### Instalacja

```bash
# 1. Klonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# 2. Zainstaluj wszystkie komponenty
sudo ./citadel.sh install-all

# 3. Skonfiguruj do użytku sieciowego
sudo ./citadel.sh configure-system

# 4. Włącz ścisły firewall
sudo ./citadel.sh firewall-strict

# 5. Zainstaluj monitorowanie
sudo ./citadel.sh install-dashboard
```

### Konfiguracja Sieci

```bash
# 1. Ustaw statyczny IP (przykład: 192.168.1.10)
sudo nano /etc/systemd/network/20-wired.network

# Dodaj:
[Match]
Name=eth0

[Network]
Address=192.168.1.10/24
Gateway=192.168.1.1
DNS=127.0.0.1

# 2. Zezwól na DNS z sieci
sudo nano /etc/coredns/Corefile

# Zmień:
.:53 {
    bind 192.168.1.10  # Nasłuchuj na interfejsie sieciowym
    forward . 127.0.0.1:5300
    cache 3600
    prometheus :9153
}

# 3. Skonfiguruj firewall dla sieci
sudo nano /etc/nftables.conf

# Dodaj:
table inet citadel {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Zezwól na DNS z lokalnej sieci
        ip saddr 192.168.1.0/24 tcp dport 53 accept
        ip saddr 192.168.1.0/24 udp dport 53 accept
        
        # Zezwól na ustanowione połączenia
        ct state established,related accept
    }
}

# 4. Restartuj usługi
sudo systemctl restart coredns nftables
```

### Konfiguracja Klienta

**Na każdej maszynie klienckiej:**

```bash
# Metoda 1: NetworkManager
sudo nmcli connection modify "Wired connection 1" ipv4.dns "192.168.1.10"
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"

# Metoda 2: Manualna
sudo nano /etc/resolv.conf
# Dodaj:
nameserver 192.168.1.10

# Metoda 3: DHCP (na routerze)
# Ustaw serwer DNS na 192.168.1.10
```

### Monitorowanie

```bash
# Wyświetl statystyki w czasie rzeczywistym
citadel-top

# Sprawdź wydajność cache
sudo ./citadel.sh cache-stats

# Monitoruj zapytania
sudo journalctl -u coredns -f

# Wyświetl zablokowane domeny
sudo ./citadel.sh adblock-stats
```

---

## 🌐 Konfiguracja Trybu Gateway

**Scenariusz:** Cytadela jako brama sieciowa, chroniąca całą sieć domową/biurową.

**Uwaga:** Tryb gateway jest planowany dla v3.2 (Q1 2026). To jest podgląd.

### Wymagania

- 1 maszyna Linux z 2 interfejsami sieciowymi
- 4 GB RAM minimum
- Połączenie WAN (do internetu)
- Połączenie LAN (do lokalnej sieci)

### Instalacja

```bash
# 1. Zainstaluj Cytadelę
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./citadel.sh install-all

# 2. Uruchom kreator gateway (v3.2+)
sudo ./citadel.sh gateway-wizard

# To zrobi:
# - Skonfiguruje interfejsy sieciowe (WAN/LAN)
# - Skonfiguruje serwer DHCP
# - Skonfiguruje NAT/routing
# - Włączy przekazywanie DNS
# - Skonfiguruje firewall
```

### Konfiguracja Manualna (v3.1)

```bash
# 1. Skonfiguruj interfejsy
sudo nano /etc/systemd/network/10-wan.network
[Match]
Name=eth0

[Network]
DHCP=yes

sudo nano /etc/systemd/network/20-lan.network
[Match]
Name=eth1

[Network]
Address=192.168.100.1/24
DHCPServer=yes

# 2. Włącz przekazywanie IP
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# 3. Skonfiguruj NAT
sudo nano /etc/nftables.conf
table inet citadel_gateway {
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "eth0" masquerade
    }
}

# 4. Skonfiguruj przekazywanie DNS
sudo nano /etc/coredns/Corefile
.:53 {
    bind 192.168.100.1
    forward . 127.0.0.1:5300
    cache 3600
}

# 5. Restartuj usługi
sudo systemctl restart systemd-networkd coredns nftables
```

### Konfiguracja Klienta

Klienci automatycznie otrzymają:
- Adres IP przez DHCP (192.168.100.x)
- Serwer DNS (192.168.100.1)
- Bramę (192.168.100.1)

Nie potrzeba ręcznej konfiguracji!

---

## 🍓 Konfiguracja Raspberry Pi

**Scenariusz:** Niskoenergetyczny serwer DNS dla sieci domowej.

### Wymagania

- Raspberry Pi 3/4/5
- 2 GB RAM minimum
- Karta SD (16 GB+)
- Arch Linux ARM lub Raspbian

### Instalacja

```bash
# 1. Zaktualizuj system
sudo pacman -Syu  # Arch ARM
# LUB
sudo apt update && sudo apt upgrade  # Raspbian

# 2. Zainstaluj zależności
sudo pacman -S dnscrypt-proxy coredns nftables  # Arch ARM
# LUB
# Instalacja manualna dla Raspbian (zobacz docs)

# 3. Klonuj Cytadelę
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# 4. Zainstaluj (tryb CLI zalecany)
sudo ./citadel.sh install-all

# 5. Skonfiguruj
sudo ./citadel.sh configure-system
sudo ./citadel.sh firewall-safe
```

### Optymalizacja dla Pi

```bash
# 1. Zmniejsz rozmiar cache (oszczędź RAM)
sudo nano /etc/coredns/Corefile
# Zmień cache z 3600 na 1800

# 2. Wyłącz niepotrzebne usługi
sudo systemctl disable bluetooth
sudo systemctl disable cups

# 3. Włącz swap (jeśli potrzebne)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 4. Monitoruj zasoby
htop
sudo ./citadel.sh cache-stats
```

### Wskazówki Wydajności

- Używaj przewodowego Ethernet (nie WiFi)
- Używaj szybkiej karty SD (Class 10+)
- Trzymaj system zaktualizowany
- Monitoruj temperaturę (zachowaj < 80°C)

---

## 🖥️ Konfiguracja Multi-Urządzenia

**Scenariusz:** Wielokrotne urządzenia używające serwera DNS Cytadela.

### Architektura

```
Internet
    ↓
Router (192.168.1.1)
    ↓
Serwer Cytadela (192.168.1.10)
    ↓
├── Laptop (192.168.1.20)
├── Desktop (192.168.1.21)
├── Telefon (192.168.1.22)
└── Tablet (192.168.1.23)
```

### Konfiguracja Serwera

```bash
# 1. Zainstaluj Cytadelę na serwerze
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./citadel.sh install-all

# 2. Skonfiguruj do użytku sieciowego
sudo nano /etc/coredns/Corefile
.:53 {
    bind 192.168.1.10
    forward . 127.0.0.1:5300
    cache 3600
}

# 3. Zezwól na dostęp sieciowy
sudo nano /etc/nftables.conf
# Dodaj reguły zezwalające na DNS z 192.168.1.0/24

# 4. Restartuj usługi
sudo systemctl restart coredns nftables
```

### Konfiguracja Klienta

**Linux:**
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.dns "192.168.1.10"
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"
```

**Windows:**
```
Panel Sterowania → Sieć → Zmień ustawienia karty
→ Kliknij prawym na połączenie → Właściwości
→ IPv4 → Właściwości
→ Użyj następującego serwera DNS: 192.168.1.10
```

**macOS:**
```
Preferencje Systemowe → Sieć
→ Wybierz połączenie → Zaawansowane
→ DNS → Dodaj 192.168.1.10
```

**Android:**
```
Ustawienia → WiFi → Długie naciśnięcie sieci
→ Modyfikuj sieć → Opcje zaawansowane
→ Ustawienia IP: Statyczne
→ DNS 1: 192.168.1.10
```

**iOS:**
```
Ustawienia → WiFi → (i) obok sieci
→ Skonfiguruj DNS → Manualne
→ Dodaj Serwer: 192.168.1.10
```

---

## 🔧 Rozwiązywanie Problemów

### Częste Problemy

**DNS nie rozwiązuje:**
```bash
# Sprawdź status serwera
sudo ./citadel.sh status

# Testuj DNS lokalnie
dig +short google.com @192.168.1.10

# Sprawdź firewall
sudo nft list ruleset | grep 53
```

**Wolna wydajność:**
```bash
# Sprawdź statystyki cache
sudo ./citadel.sh cache-stats

# Zwiększ rozmiar cache
sudo nano /etc/coredns/Corefile
# Zmień cache na 7200

# Restartuj CoreDNS
sudo systemctl restart coredns
```

**Klienci nie mogą się połączyć:**
```bash
# Sprawdź reguły firewall
sudo nft list ruleset

# Testuj łączność
ping 192.168.1.10  # Z klienta

# Sprawdź logi
sudo journalctl -u coredns -f
```

---

## 📚 Dodatkowe Zasoby

- [Pełny Manual (PL)](MANUAL_PL.md)
- [Pełny Manual (EN)](MANUAL_EN.md)
- [Przewodnik Szybkiego Startu](quick-start.md)
- [FAQ](FAQ.md)
- [Referencja Poleceń](commands.md)

---

**Ostatnia aktualizacja:** 2026-01-31
**Wersja:** 3.1.1
