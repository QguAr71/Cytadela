# 📚 Cytadela v3.2 - Dokumentacja Modułów Unifikowanych

**Wersja:** 3.2.0
**Utworzono:** 2026-02-04
**Status:** Faza 0-4 Zakończona (71% implementacji)

---

## 📋 Spis Treści

1. [Przegląd Architektury](#przegląd-architektury)
2. [unified-recovery.sh](#unified-recovery)
3. [unified-install.sh](#unified-install)
4. [unified-security.sh](#unified-security)
5. [unified-network.sh](#unified-network)
6. [Tabela Migracji Poleceń](#tabela-migracji-poleceń)
7. [Kompatybilność wsteczna](#kompatybilność-wsteczna)
8. [Przewodnik Dewelopera](#przewodnik-dewelopera)

---

## 🏗️ Przegląd Architektury

### **Czym są Moduły Unifikowane?**

Cytadela v3.2 wprowadza **moduły unifikowane** - nową architekturę, która konsoliduje 29 rozproszonych modułów w 7 skoncentrowanych, łatwych w utrzymaniu modułów. Każdy moduł unifikowany obsługuje specyficzny obszar funkcjonalności.

### **Korzyści**
- **Zmniejszona Złożoność:** 29 → 7 modułów (-75%)
- **Pojedyncze Źródło Prawdy:** Brak więcej rozproszonych funkcji
- **Lepsza Łatwość Utrzymania:** Spójne interfejsy i wzorce
- **Ulepszone Testowanie:** Izolowane, skoncentrowane moduły
- **Kompatybilność Wsteczna:** Wszystkie stare polecenia nadal działają

### **Struktura Modułów Unifikowanych**
```
modules/unified/
├── unified-recovery.sh   (~1,100 LOC) - Odzyskiwanie awaryjne i systemu
├── unified-install.sh    (~1,500 LOC) - Wszystkie funkcje instalacji
├── unified-security.sh   (~560 LOC)  - Bezpieczeństwo, integralność, lokalizacja
├── unified-network.sh    (~570 LOC)  - Narzędzia sieciowe i IPv6
├── unified-adblock.sh    (~800 LOC)  - Blokowanie reklam (Faza 5)
├── unified-backup.sh     (~700 LOC)  - Kopia zapasowa i auto-aktualizacja (Faza 5)
└── unified-monitor.sh    (~600 LOC)  - Monitorowanie i diagnostyka (Faza 6)
```

---

## 🔄 unified-recovery.sh

**Cel:** Funkcje odzyskiwania awaryjnego i przywracania systemu

### **Zawarte Funkcje**
- **Tryb Paniki:** `panic_bypass()`, `panic_restore()`, `panic_status()`
- **Sieć Awaryjna:** `emergency_network_restore()`, `emergency_network_fix()`
- **Przywracanie Systemu:** `restore_system()`, `restore_system_default()`
- **Odzyskiwanie IPv6:** Głęboki reset IPv6 i inteligentne odzyskiwanie
- **Wykrywanie VPN:** Automatyczne obsługiwanie VPN w scenariuszach odzyskiwania

### **Dostępne Polecenia**

| Polecenie | Opis | Przykład |
|-----------|------|----------|
| `citadel recovery panic-bypass` | Tymczasowo wyłącza ochronę DNS | `citadel recovery panic-bypass` |
| `citadel recovery panic-restore` | Przywraca ochronę DNS | `citadel recovery panic-restore` |
| `citadel recovery panic-status` | Pokazuje status trybu paniki | `citadel recovery panic-status` |
| `citadel recovery emergency-network-restore` | Pełne odzyskiwanie sieci | `citadel recovery emergency-network-restore` |
| `citadel recovery emergency-network-fix` | Szybka naprawa DNS | `citadel recovery emergency-network-fix` |
| `citadel recovery restore-system` | Przywraca system z kopii zapasowej | `citadel recovery restore-system` |
| `citadel recovery restore-system-default` | Przywraca ustawienia fabryczne | `citadel recovery restore-system-default` |

### **Kluczowe Funkcje**
- **Auto-rollback:** Tryb paniki automatycznie przywraca się po timeout
- **Świadomy VPN:** Wykrywa i zachowuje połączenia VPN podczas odzyskiwania
- **Wielostopniowe odzyskiwanie:** DNS → Firewall → Sieć → Testowanie
- **Integracja z kopią zapasową:** Używa kopii zapasowych systemu do przywracania

### **Przykłady**
```bash
# Odzyskiwanie awaryjne gdy internet jest uszkodzony
sudo citadel recovery emergency-network-restore

# Tymczasowy tryb paniki (5 minut auto-rollback)
sudo citadel recovery panic-bypass 300

# Przywracanie systemu z kopii zapasowej
sudo citadel recovery restore-system
```

---

## ⚙️ unified-install.sh

**Cel:** Kompletny system instalacji dla wszystkich komponentów Cytadeli

### **Zawarte Funkcje**
- **Instalacja DNSCrypt:** `install_dnscrypt()`
- **Instalacja CoreDNS:** `install_coredns()`
- **Instalacja Firewall:** `install_nftables()`, `firewall_safe()`, `firewall_strict()`
- **Konfiguracja Systemu:** `configure_system()`
- **Instalacja Dashboard:** `install_dashboard()`
- **Zarządzanie Zależnościami:** `check_dependencies_install()`
- **Kompletna Instalacja:** `install_all()`, `install_wizard()`

### **Dostępne Polecenia**

| Polecenie | Opis | Przykład |
|-----------|------|----------|
| `citadel install dnscrypt` | Instaluje DNSCrypt-Proxy | `citadel install dnscrypt` |
| `citadel install coredns` | Instaluje CoreDNS | `citadel install coredns` |
| `citadel install nftables` | Instaluje firewall NFTables | `citadel install nftables` |
| `citadel install dashboard` | Instaluje terminal dashboard | `citadel install dashboard` |
| `citadel install all` | Kompletna instalacja systemu | `citadel install all` |
| `citadel install wizard` | Interaktywny kreator instalacji | `citadel install wizard` |
| `citadel install check-deps` | Instaluje brakujące zależności | `citadel install check-deps` |
| `citadel install firewall-safe` | Ustawia bezpieczny tryb firewall | `citadel install firewall-safe` |
| `citadel install firewall-strict` | Ustawia restrykcyjny tryb firewall | `citadel install firewall-strict` |
| `citadel install configure-system` | Konfiguruje system DNS | `citadel install configure-system` |

### **Kluczowe Funkcje**
- **Modularna Instalacja:** Instaluje indywidualne komponenty lub wszystko
- **Rozwiązywanie Zależności:** Automatyczne wykrywanie menedżera pakietów i instalacja
- **Tryby Firewall:** Bezpieczna vs restrykcyjna ochrona przed wyciekami DNS
- **Integracja Systemowa:** Automatyczne wyłączanie systemd-resolved
- **Interaktywny Kreator:** Uproszczona konfiguracja dla nowych użytkowników

### **Przykłady**
```bash
# Kompletna instalacja
sudo citadel install all

# Instalacja indywidualnych komponentów
sudo citadel install dnscrypt
sudo citadel install coredns
sudo citadel install nftables

# Konfiguracja trybu firewall
sudo citadel install firewall-strict

# Instalacja brakujących zależności
sudo citadel install check-deps
```

---

## 🔒 unified-security.sh

**Cel:** Monitorowanie bezpieczeństwa, weryfikacja integralności i kontrola dostępu

### **Zawarte Funkcje**
- **Weryfikacja Integralności:** `integrity_init()`, `integrity_check()`, `integrity_status()`
- **Bezpieczeństwo Bazowane na Lokalizacji:** `location_check()`, `location_add_trusted()`, `location_remove_trusted()`
- **Bezpieczeństwo Łańcucha Dostaw:** `supply_chain_init()`, `supply_chain_verify()`
- **Sprawdzenie Ghost:** `ghost_check()` - otwarte porty i podejrzane procesy
- **Debug NFT:** `nft_debug_on()`, `nft_debug_off()`, `nft_debug_status()`

### **Dostępne Polecenia**

| Polecenie | Opis | Przykład |
|-----------|------|----------|
| `citadel security integrity-init` | Inicjalizuje manifest integralności | `citadel security integrity-init` |
| `citadel security integrity-check` | Weryfikuje integralność plików | `citadel security integrity-check` |
| `citadel security integrity-status` | Pokazuje status integralności | `citadel security integrity-status` |
| `citadel security location-check` | Sprawdza bezpieczeństwo aktualnej sieci | `citadel security location-check` |
| `citadel security location-add-trusted <SSID>` | Dodaje zaufaną sieć WiFi | `citadel security location-add-trusted MyHomeWiFi` |
| `citadel security location-remove-trusted <SSID>` | Usuwa zaufaną sieć | `citadel security location-remove-trusted PublicWiFi` |
| `citadel security location-list-trusted` | Lista zaufanych sieci | `citadel security location-list-trusted` |
| `citadel security supply-chain-init` | Inicjalizuje weryfikację łańcucha dostaw | `citadel security supply-chain-init` |
| `citadel security supply-chain-verify` | Weryfikuje łańcuch dostaw | `citadel security supply-chain-verify` |
| `citadel security supply-chain-status` | Pokazuje status łańcucha dostaw | `citadel security supply-chain-status` |
| `citadel security ghost-check` | Audyt bezpieczeństwa dla otwartych portów | `citadel security ghost-check` |
| `citadel security nft-debug-on` | Włącza logowanie debug NFTables | `citadel security nft-debug-on` |
| `citadel security nft-debug-off` | Wyłącza logowanie debug NFTables | `citadel security nft-debug-off` |
| `citadel security nft-debug-status` | Pokazuje status debug | `citadel security nft-debug-status` |
| `citadel security nft-debug-logs` | Pokazuje logi debug | `citadel security nft-debug-logs` |

### **Kluczowe Funkcje**
- **Integralność Plików:** Weryfikacja SHA256 z obejściem trybu dewelopera
- **Świadomość Lokalizacji:** Polityki bezpieczeństwa bazowane na sieciach WiFi
- **Łańcuch Dostaw:** Weryfikacja źródeł aktualizacji i binariów
- **Audyt Bezpieczeństwa:** Wykrywanie podejrzanych procesów i otwartych portów
- **Debugowanie Firewall:** Logowanie i monitorowanie NFTables w czasie rzeczywistym

### **Przykłady**
```bash
# Inicjalizacja sprawdzania integralności
sudo citadel security integrity-init

# Sprawdzenie bezpieczeństwa aktualnej sieci
sudo citadel security location-check

# Dodanie zaufanej sieci WiFi
sudo citadel security location-add-trusted "OfficeWiFi"

# Uruchomienie audytu bezpieczeństwa
sudo citadel security ghost-check

# Włączenie debugowania firewall
sudo citadel security nft-debug-on
```

---

## 🌐 unified-network.sh

**Cel:** Konfiguracja sieci i narzędzia zarządzania IPv6

### **Zawarte Funkcje**
- **Prywatność IPv6:** `ipv6_privacy_auto_ensure()`, `ipv6_privacy_on()`, `ipv6_privacy_off()`, `ipv6_privacy_status()`
- **Narzędzia Edycji:** `edit_config()`, `edit_dnscrypt()`, `show_logs()`
- **Zarządzanie Portami:** `fix_port_conflicts()`
- **Powiadomienia:** `notify_enable()`, `notify_disable()`, `notify_status()`, `notify_test()`

### **Dostępne Polecenia**

| Polecenie | Opis | Przykład |
|-----------|------|----------|
| `citadel network ipv6-privacy-auto` | Auto-zapewnienie prywatności IPv6 | `citadel network ipv6-privacy-auto` |
| `citadel network ipv6-privacy-on` | Włącza rozszerzenia prywatności IPv6 | `citadel network ipv6-privacy-on` |
| `citadel network ipv6-privacy-off` | Wyłącza rozszerzenia prywatności IPv6 | `citadel network ipv6-privacy-off` |
| `citadel network ipv6-privacy-status` | Pokazuje status prywatności IPv6 | `citadel network ipv6-privacy-status` |
| `citadel network edit` | Edytuje konfigurację CoreDNS | `citadel network edit` |
| `citadel network edit-dnscrypt` | Edytuje konfigurację DNSCrypt | `citadel network edit-dnscrypt` |
| `citadel network logs` | Pokazuje logi systemowe | `citadel network logs coredns` |
| `citadel network logs <linie>` | Pokazuje logi z własną liczbą linii | `citadel network logs 100` |
| `citadel network fix-ports` | Naprawia konflikty portów | `citadel network fix-ports` |
| `citadel network notify-enable` | Włącza powiadomienia | `citadel network notify-enable` |
| `citadel network notify-disable` | Wyłącza powiadomienia | `citadel network notify-disable` |
| `citadel network notify-status` | Pokazuje status powiadomień | `citadel network notify-status` |
| `citadel network notify-test` | Testuje powiadomienia | `citadel network notify-test` |

### **Kluczowe Funkcje**
- **Prywatność IPv6:** Automatyczne zarządzanie adresami prywatnymi
- **Edycja Konfiguracji:** Wbudowane edytory dla konfiguracji DNS
- **Zarządzanie Logami:** Scentralizowane przeglądanie logów z filtrowaniem
- **Rozwiązywanie Konfliktów Portów:** Automatyczne wykrywanie i naprawianie
- **System Powiadomień:** Powiadomienia desktopowe i systemowe

### **Przykłady**
```bash
# Zapewnienie prywatności IPv6
sudo citadel network ipv6-privacy-auto

# Edycja konfiguracji CoreDNS
sudo citadel network edit

# Pokazanie logów CoreDNS
sudo citadel network logs coredns

# Włączenie powiadomień
sudo citadel network notify-enable

# Testowanie powiadomień
sudo citadel network notify-test
```

---

## 🔄 Tabela Migracji Poleceń

### **Migracja Poleceń Odzyskiwania**

| Polecenie Legacy | Nowe Polecenie Unifikowane | Status |
|------------------|----------------------------|--------|
| `panic-bypass` | `citadel recovery panic-bypass` | ✅ Zmigrowane |
| `panic-restore` | `citadel recovery panic-restore` | ✅ Zmigrowane |
| `panic-status` | `citadel recovery panic-status` | ✅ Zmigrowane |
| `emergency-network-restore` | `citadel recovery emergency-network-restore` | ✅ Zmigrowane |
| `restore-system` | `citadel recovery restore-system` | ✅ Zmigrowane |
| `restore-system-default` | `citadel recovery restore-system-default` | ✅ Zmigrowane |

### **Migracja Poleceń Instalacji**

| Polecenie Legacy | Nowe Polecenie Unifikowane | Status |
|------------------|----------------------------|--------|
| `install-dnscrypt` | `citadel install dnscrypt` | ✅ Zmigrowane |
| `install-coredns` | `citadel install coredns` | ✅ Zmigrowane |
| `install-nftables` | `citadel install nftables` | ✅ Zmigrowane |
| `install-dashboard` | `citadel install dashboard` | ✅ Zmigrowane |
| `install-all` | `citadel install all` | ✅ Zmigrowane |
| `install-wizard` | `citadel install wizard` | ✅ Zmigrowane |
| `firewall-safe` | `citadel install firewall-safe` | ✅ Zmigrowane |
| `firewall-strict` | `citadel install firewall-strict` | ✅ Zmigrowane |
| `configure-system` | `citadel install configure-system` | ✅ Zmigrowane |
| `check-dependencies` | `citadel install check-deps` | ✅ Zmigrowane |

### **Migracja Poleceń Bezpieczeństwa**

| Polecenie Legacy | Nowe Polecenie Unifikowane | Status |
|------------------|----------------------------|--------|
| `integrity-init` | `citadel security integrity-init` | ✅ Zmigrowane |
| `integrity-check` | `citadel security integrity-check` | ✅ Zmigrowane |
| `integrity-status` | `citadel security integrity-status` | ✅ Zmigrowane |
| `location-status` | `citadel security location-check` | ✅ Zmigrowane |
| `location-add-trusted` | `citadel security location-add-trusted` | ✅ Zmigrowane |
| `supply-chain-init` | `citadel security supply-chain-init` | ✅ Zmigrowane |
| `supply-chain-verify` | `citadel security supply-chain-verify` | ✅ Zmigrowane |
| `ghost-check` | `citadel security ghost-check` | ✅ Zmigrowane |
| `nft-debug-on` | `citadel security nft-debug-on` | ✅ Zmigrowane |

### **Migracja Poleceń Sieci**

| Polecenie Legacy | Nowe Polecenie Unifikowane | Status |
|------------------|----------------------------|--------|
| `ipv6-privacy-on` | `citadel network ipv6-privacy-on` | ✅ Zmigrowane |
| `ipv6-privacy-off` | `citadel network ipv6-privacy-off` | ✅ Zmigrowane |
| `ipv6-privacy-auto` | `citadel network ipv6-privacy-auto` | ✅ Zmigrowane |
| `edit` | `citadel network edit` | ✅ Zmigrowane |
| `edit-dnscrypt` | `citadel network edit-dnscrypt` | ✅ Zmigrowane |
| `logs` | `citadel network logs` | ✅ Zmigrowane |
| `fix-ports` | `citadel network fix-ports` | ✅ Zmigrowane |
| `notify-enable` | `citadel network notify-enable` | ✅ Zmigrowane |

---

## 🔙 Kompatybilność Wsteczna

### **100% Gwarancja Kompatybilności Wstecznej**

Wszystkie polecenia legacy nadal działają dokładnie tak samo jak wcześniej. Architektura unifikowana używa:

1. **Warstwy Tłumaczenia Poleceń:** Polecenia legacy są automatycznie tłumaczone na format unifikowany
2. **System Aliasów:** Stare funkcje modułów pozostają dostępne
3. **Stopniowa Migracja:** Użytkownicy mogą migrować we własnym tempie

### **Przykłady Tłumaczenia**
```bash
# Wszystkie te działają identycznie:
citadel emergency                # Legacy (nadal działa)
citadel recovery panic-bypass    # Unifikowane (zalecane)

citadel install-all             # Legacy (nadal działa)
citadel install all             # Unifikowane (zalecane)

citadel ghost-check             # Legacy (nadal działa)
citadel security ghost-check    # Unifikowane (zalecane)
```

### **Harmonogram Migracji**
- **Faza 0-4:** Polecenia legacy w pełni wspierane
- **Faza 5-7:** Aktualizacje dokumentacji do poleceń unifikowanych
- **v3.3.0:** Ostrzeżenia o wycofaniu poleceń legacy
- **v4.0.0:** Usunięcie poleceń legacy (jeśli potrzebne)

---

## 👨‍💻 Przewodnik Dewelopera

### **Dodawanie Nowych Funkcji Unifikowanych**

1. **Wybór Modułu:** Określ który moduł unifikowany pasuje do funkcjonalności
2. **Dodanie Funkcji:** Zaimplementuj w odpowiednim `modules/unified/unified-*.sh`
3. **Aktualizacja Dyspozytora:** Dodaj case w `citadel.sh` dla nowych poleceń
4. **Dodanie i18n:** Dodaj stringi do `lib/i18n/*/recovery/*.sh` jeśli potrzebne
5. **Testowanie:** Zapewnij kompatybilność wsteczną i nową funkcjonalność

### **Standardy Struktury Modułów**

Każdy moduł unifikowany przestrzega tego wzorca:
```bash
#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-[MODULE] MODULE v3.2                                ║
# ║  [Krótki opis]                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Stałe konfiguracyjne
MODULE_CONFIG_VAR="value"

# Publiczne funkcje API (wywoływane przez dyspozytor)
function_name() {
    # Implementacja
}

# Prywatne funkcje pomocnicze (prefiks z _)
_helper_function() {
    # Implementacja
}
```

### **Testowanie Modułów Unifikowanych**

```bash
# Testowanie indywidualnych modułów
sudo ./citadel.sh recovery panic-status
sudo ./citadel.sh install check-deps
sudo ./citadel.sh security integrity-check
sudo ./citadel.sh network ipv6-privacy-status

# Testowanie kompatybilności wstecznej
sudo ./citadel.sh panic-status          # Powinno nadal działać
sudo ./citadel.sh check-dependencies    # Powinno nadal działać
sudo ./citadel.sh ghost-check           # Powinno nadal działać
```

---

## 📞 Wsparcie

### **Uzyskiwanie Pomocy**
- **Dokumentacja:** Ten dokument i REFACTORING-V3.2-ROADMAP.md
- **Polecenia:** `citadel help` lub `citadel --help`
- **Problemy:** Issues na GitHub z etykietą `unified-modules`
- **Migracja:** MIGRATION-v3.1-to-v3.2.md (Faza 7)

### **Informacje o Wersji**
- **Aktualna Wersja:** v3.2.0-alpha (Faza 0-4 zakończona)
- **Następny Kamień Milowy:** Faza 5 (Moduły Adblock i Backup)
- **Pełne Wydanie:** Oczekiwane Q1 2026

---

**Ostatnia Aktualizacja:** 2026-02-04
**Postęp Implementacji:** Faza 0-4 Zakończona (71%)
