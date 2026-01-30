# CYTADELA++ - ROADMAP DLA UŻYTKOWNIKÓW DOMOWYCH

**Wersja:** v3.2+  
**Grupa docelowa:** Użytkownicy domowi (początkujący → zaawansowani) + małe firmy  
**Filozofia:** Prostota, bezpieczeństwo, prywatność - bez korporacyjnego bełkotu

---

## 🏠 SCENARIUSZE UŻYCIA

### 1. **Pojedynczy komputer** (obecne)
- Ochrona DNS na jednym PC/laptopie
- Adblock dla całego systemu
- Prywatność IPv6
- **Dla:** Użytkownik indywidualny

### 2. **Sieć domowa** (nowe - priorytet!)
- Cytadela++ jako gateway dla całej sieci
- Ochrona wszystkich urządzeń (PC, telefony, IoT)
- Centralne zarządzanie
- **Dla:** Rodzina, smart home

### 3. **Małe biuro** (nowe)
- Ochrona sieci firmowej (5-20 urządzeń)
- Statystyki użycia
- Proste zarządzanie
- **Dla:** Freelancerzy, małe firmy

---

## 🎯 PROPOZYCJE ROZWOJU (v3.2+)

### **PRIORYTET 1: Cytadela++ jako Gateway Sieciowy** 🏆

**Problem:** Obecnie Cytadela++ chroni tylko jeden komputer. Użytkownicy chcą chronić całą sieć domową.

**Rozwiązanie:** Tryb "Network Gateway" na dedykowanym komputerze.

#### Funkcjonalność:
```bash
# Instalacja w trybie gateway
sudo cytadela++ install-gateway

# Konfiguracja
sudo cytadela++ gateway-setup
# Wybierz interfejs WAN (internet)
# Wybierz interfejs LAN (sieć domowa)
# Ustaw zakres DHCP
```

#### Co robi:
- **DHCP server** - automatyczne przydzielanie IP urządzeniom
- **DNS dla całej sieci** - wszystkie urządzenia używają Cytadela++
- **Firewall** - ochrona całej sieci
- **Adblock** - blokowanie reklam dla wszystkich urządzeń
- **Statystyki** - które urządzenie co robi

#### Wymagania sprzętowe:
| Sieć | CPU | RAM | Dysk | Interfejsy |
|------|-----|-----|------|------------|
| **Mała** (5-10 urządzeń) | Pentium 4 / Core 2 Duo | 2 GB | 8 GB | 2x Ethernet |
| **Średnia** (10-30 urządzeń) | Core i3 / Ryzen 3 | 4 GB | 16 GB | 2x Ethernet |
| **Duża** (30-50 urządzeń) | Core i5 / Ryzen 5 | 8 GB | 32 GB | 2x Ethernet (1 Gbps) |

**Przykładowy stary komputer:**
- Dell Optiplex 755 (2008) - **idealny!**
- HP Compaq 8000 Elite
- Lenovo ThinkCentre M58
- **Koszt:** 100-200 zł (używany)

#### Komendy:
```bash
# Status gateway
sudo cytadela++ gateway-status

# Lista urządzeń w sieci
sudo cytadela++ gateway-devices

# Statystyki per urządzenie
sudo cytadela++ gateway-stats <IP>

# Blokuj urządzenie (parental control)
sudo cytadela++ gateway-block <IP>
sudo cytadela++ gateway-unblock <IP>
```

---

### **PRIORYTET 2: Proste Zarządzanie dla Początkujących**

**Problem:** Obecny interface to CLI - może być trudny dla początkujących.

#### Opcja A: Terminal UI (TUI) - ZALECANE
```bash
sudo cytadela++ tui
```

**Interfejs w terminalu (ncurses):**
```
┌─────────────────── Cytadela++ v3.2 ───────────────────┐
│                                                        │
│  Status:  ✓ Działa                                    │
│  DNS:     ✓ DNSCrypt + CoreDNS                        │
│  Adblock: ✓ 1.2M domen zablokowanych                  │
│  Firewall: ✓ STRICT mode                              │
│                                                        │
│  [1] Pokaż statystyki                                 │
│  [2] Zmień profil blocklist                           │
│  [3] Zarządzaj urządzeniami (gateway)                 │
│  [4] Backup/Restore                                   │
│  [5] Ustawienia                                       │
│  [Q] Wyjście                                          │
│                                                        │
└────────────────────────────────────────────────────────┘
```

**Zalety:**
- Działa przez SSH
- Szybki, lekki
- Nie wymaga GUI
- Idealny dla gateway

#### Opcja B: Web UI (opcjonalnie)
```bash
sudo cytadela++ webui-install
# Dostępne na: http://192.168.1.1:8080
```

**Tylko dla:**
- Użytkowników którzy NAPRAWDĘ nie chcą CLI
- Zarządzanie z telefonu/tabletu

**Wymagania:**
- Lekki backend (Python Flask / Go)
- Podstawowe funkcje (status, stats, blocklist)
- **NIE** pełny dashboard jak Pi-hole (za ciężki)

---

### **PRIORYTET 3: Parental Control (Kontrola Rodzicielska)**

**Dla:** Rodzice chcący chronić dzieci w internecie.

#### Funkcje:
```bash
# Utwórz profil dziecka
sudo cytadela++ parental-add "Laptop Tomka" 192.168.1.50

# Ustaw ograniczenia
sudo cytadela++ parental-set 192.168.1.50 --schedule "08:00-20:00"
sudo cytadela++ parental-set 192.168.1.50 --blocklist kids-safe

# Blokuj kategorie
sudo cytadela++ parental-block 192.168.1.50 --category adult
sudo cytadela++ parental-block 192.168.1.50 --category gambling
sudo cytadela++ parental-block 192.168.1.50 --category social-media

# Raport aktywności
sudo cytadela++ parental-report 192.168.1.50
```

#### Profile blocklist:
- `kids-safe` - bezpieczny dla dzieci (blokuje adult, gambling, violence)
- `teens` - dla nastolatków (blokuje adult, gambling)
- `work` - tryb pracy (blokuje social media, streaming, gaming)

---

### **PRIORYTET 4: Proste Statystyki i Alerty**

**Problem:** Użytkownicy chcą wiedzieć co się dzieje, ale bez Grafany.

#### Dashboard w terminalu:
```bash
sudo cytadela++ dashboard

┌─────────────────── Cytadela++ Dashboard ──────────────────┐
│                                                            │
│  Ostatnie 24h:                                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Zapytania DNS:        12,453                              │
│  Zablokowane:          3,721 (30%)                         │
│  Cache hit rate:       85%                                 │
│  Średni czas:          12 ms                               │
│                                                            │
│  Top zablokowane domeny:                                   │
│  1. doubleclick.net           421 razy                     │
│  2. googleadservices.com      312 razy                     │
│  3. facebook.com/tr           287 razy                     │
│                                                            │
│  Urządzenia w sieci: 8                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  192.168.1.10 (PC-Salon)      3,421 zapytań               │
│  192.168.1.50 (Laptop-Tomek)  2,103 zapytań               │
│  192.168.1.51 (iPhone-Ania)   1,876 zapytań               │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

#### Email/SMS alerty (opcjonalnie):
```bash
# Konfiguruj alerty
sudo cytadela++ alerts-setup

# Alerty dla:
# - Usługa nie działa (critical)
# - Podejrzana aktywność DNS (warning)
# - Duża liczba zablokowanych zapytań (info)
```

---

### **PRIORYTET 5: Automatyczne Aktualizacje (bezobsługowe)**

**Problem:** Użytkownicy zapominają aktualizować.

```bash
# Włącz auto-update WSZYSTKIEGO
sudo cytadela++ auto-update-full enable

# Co się aktualizuje:
# - Blocklist (już jest w v3.1)
# - DNSCrypt resolver list
# - CoreDNS
# - Skrypty Cytadela++
# - Reguły firewall
```

**Bezpieczeństwo:**
- Backup przed każdą aktualizacją
- Rollback automatyczny jeśli coś nie działa
- Powiadomienie o aktualizacji

---

### **PRIORYTET 6: Łatwa Migracja/Backup**

**Problem:** Użytkownik zmienia komputer lub reinstaluje system.

```bash
# Backup WSZYSTKIEGO (1 komenda)
sudo cytadela++ full-backup
# Zapisuje do: /var/lib/cytadela/backups/full-backup-YYYYMMDD.tar.gz

# Restore na nowym komputerze
sudo cytadela++ full-restore /path/to/backup.tar.gz
# Przywraca: config, blocklist, custom rules, statystyki
```

---

## 🏗️ CYTADELA++ JAKO GATEWAY - SZCZEGÓŁY TECHNICZNE

### **Architektura:**

```
Internet (WAN)
      │
      ▼
┌─────────────────────────────────────┐
│  Cytadela++ Gateway (stary PC)      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ WAN Interface (eth0)        │   │
│  │ IP: DHCP od ISP             │   │
│  └─────────────────────────────┘   │
│              │                      │
│              ▼                      │
│  ┌─────────────────────────────┐   │
│  │ NFTables Firewall           │   │
│  │ - NAT                       │   │
│  │ - DNS leak prevention       │   │
│  │ - Port forwarding           │   │
│  └─────────────────────────────┘   │
│              │                      │
│              ▼                      │
│  ┌─────────────────────────────┐   │
│  │ DNSCrypt + CoreDNS          │   │
│  │ - Adblock                   │   │
│  │ - Cache                     │   │
│  │ - Parental control          │   │
│  └─────────────────────────────┘   │
│              │                      │
│              ▼                      │
│  ┌─────────────────────────────┐   │
│  │ DHCP Server                 │   │
│  │ - Przydziela IP             │   │
│  │ - Ustawia DNS na siebie     │   │
│  └─────────────────────────────┘   │
│              │                      │
│              ▼                      │
│  ┌─────────────────────────────┐   │
│  │ LAN Interface (eth1)        │   │
│  │ IP: 192.168.1.1             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
      │
      ▼
Sieć domowa (LAN)
- PC, laptopy
- Telefony
- Smart TV
- IoT (Alexa, etc.)
```

### **Instalacja Gateway - Krok po kroku:**

#### 1. Przygotowanie sprzętu:
```
Potrzebne:
- Stary komputer (2 GB RAM minimum)
- 2x karta sieciowa (lub 1x + USB Ethernet)
- Kabel Ethernet do routera (WAN)
- Switch/router dla urządzeń (LAN)
```

#### 2. Instalacja systemu:
```bash
# Arch Linux (zalecane - lekki)
# Lub: Debian, Ubuntu Server

# Zainstaluj Cytadela++
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./install-refactored.sh
```

#### 3. Konfiguracja gateway:
```bash
# Uruchom wizard gateway
sudo cytadela++ gateway-wizard

# Wizard pyta:
# 1. Który interfejs to WAN? (eth0)
# 2. Który interfejs to LAN? (eth1)
# 3. Zakres IP dla DHCP? (192.168.1.100-192.168.1.200)
# 4. Profil blocklist? (balanced/aggressive/kids-safe)
# 5. Włączyć parental control? (tak/nie)
```

#### 4. Podłączenie urządzeń:
```
Router ISP → [WAN eth0] Cytadela++ [LAN eth1] → Switch → Urządzenia
```

#### 5. Test:
```bash
# Na Cytadela++
sudo cytadela++ gateway-status

# Na urządzeniu w sieci
ping 8.8.8.8  # Test internetu
nslookup google.com  # Test DNS (powinno pokazać 192.168.1.1)
```

### **Wymagania sprzętowe - szczegóły:**

#### Minimalne (5-10 urządzeń):
- **CPU:** Pentium 4 / Core 2 Duo / Atom
- **RAM:** 2 GB
- **Dysk:** 8 GB (SSD zalecane dla szybkości)
- **Sieć:** 2x 100 Mbps Ethernet
- **Pobór prądu:** ~20-30W
- **Przykłady:** Dell Optiplex 755, HP DC7800

#### Zalecane (10-30 urządzeń):
- **CPU:** Core i3 / Ryzen 3 / Celeron G
- **RAM:** 4 GB
- **Dysk:** 16 GB SSD
- **Sieć:** 2x 1 Gbps Ethernet
- **Pobór prądu:** ~30-40W
- **Przykłady:** Dell Optiplex 7010, HP 8200 Elite

#### Optymalne (30-50 urządzeń):
- **CPU:** Core i5 / Ryzen 5
- **RAM:** 8 GB
- **Dysk:** 32 GB SSD
- **Sieć:** 2x 1 Gbps Ethernet (lub 1x 2.5 Gbps)
- **Pobór prądu:** ~40-60W
- **Przykłady:** Dell Optiplex 9020, HP EliteDesk 800 G1

### **Koszty:**

| Wariant | Sprzęt | Koszt | Pobór prądu/rok | Razem/rok |
|---------|--------|-------|-----------------|-----------|
| **Budget** | Dell Optiplex 755 (używany) | 150 zł | ~175 kWh × 0.80 zł = 140 zł | **290 zł** |
| **Standard** | Dell Optiplex 7010 (używany) | 300 zł | ~260 kWh × 0.80 zł = 210 zł | **510 zł** |
| **Premium** | Nowy mini PC (N100) | 800 zł | ~130 kWh × 0.80 zł = 105 zł | **905 zł** |

**Porównanie z Pi-hole na Raspberry Pi:**
- Raspberry Pi 4 (4GB): ~400 zł + zasilacz + karta SD
- Cytadela++ na starym PC: ~150 zł (wszystko w zestawie)
- **Zaleta PC:** Więcej mocy, łatwiejszy troubleshooting, 2x Ethernet wbudowane

---

## 📋 ROADMAP - KOLEJNOŚĆ IMPLEMENTACJI

### **v3.2 - Gateway & Home Users** (priorytet!)
1. **Gateway mode** - tryb sieciowy
2. **DHCP server** - automatyczne IP
3. **Per-device stats** - statystyki per urządzenie
4. **Terminal UI (TUI)** - prosty interface
5. **Gateway wizard** - łatwa konfiguracja

### **v3.3 - Parental & Management**
6. **Parental control** - kontrola rodzicielska
7. **Time schedules** - harmonogramy (dzieci: internet 8-20)
8. **Category blocking** - blokowanie kategorii
9. **Activity reports** - raporty aktywności
10. **Email/SMS alerts** - powiadomienia

### **v3.4 - Automation & Polish**
11. **Auto-update full** - wszystko automatycznie
12. **Full backup/restore** - pełny backup 1 komendą
13. **Web UI** (opcjonalnie) - dla tych co nie lubią CLI
14. **Mobile app** (opcjonalnie) - zarządzanie z telefonu

---

## 🎯 FILOZOFIA ROZWOJU

### ✅ TAK:
- Prostota użycia
- Bezpieczeństwo i prywatność
- Niska bariera wejścia
- Działa na starym sprzęcie
- Jasna dokumentacja po polsku
- Społeczność użytkowników domowych

### ❌ NIE:
- Korporacyjny żargon
- Skomplikowane dashboardy
- Wymóg nowego sprzętu
- Płatne funkcje
- Telemetria
- "Enterprise features"

---

## 💡 PRZYKŁADOWE SCENARIUSZE

### **Scenariusz 1: Rodzina z dziećmi**
```
Sprzęt: Dell Optiplex 755 (150 zł używany)
Sieć: 2 PC, 3 telefony, Smart TV, Alexa
Funkcje: Gateway + Parental control + Adblock
Efekt: Cała rodzina chroniona, dzieci mają ograniczenia
```

### **Scenariusz 2: Freelancer / małe biuro**
```
Sprzęt: Dell Optiplex 7010 (300 zł używany)
Sieć: 3 PC, 2 laptopy, drukarki
Funkcje: Gateway + Adblock + Statystyki
Efekt: Ochrona firmowa, statystyki użycia
```

### **Scenariusz 3: Tech enthusiast**
```
Sprzęt: Mini PC N100 (800 zł nowy)
Sieć: 5 PC, 10 urządzeń IoT, NAS
Funkcje: Gateway + Wszystkie moduły + TUI
Efekt: Pełna kontrola nad siecią domową
```

---

**Plik utworzony:** 2026-01-30  
**Dla:** Użytkownicy domowi i małe firmy  
**Bez:** Korporacyjnego bełkotu 😊
