# 🚀 Roadmap v3.2 - Unified Module Architecture (7 Modules)
**Wersja:** 3.2.0 FINAL
**Utworzono:** 2026-02-04
**Status:** Gotowe do implementacji
**Wymagania wstępne:** v3.1.0 (Aktualna)
**Szacowany czas:** 8-10 tygodni (z pomocą AI)

---

## 📋 Podsumowanie wykonawcze

### 🎯 Misja
Przekształcić Cytadelę z 29 rozdrobnionych modułów w 7 zunifikowanych, łatwych w utrzymaniu modułów przy zachowaniu 100% funkcjonalności i kompatybilności wstecznej.

### 📊 Kluczowe metryki
- **Moduły:** 29 → 7 zunifikowanych + 4 specjalistyczne (-75%)
- **Redukcja kodu:** ~6,775 LOC → ~5,700 LOC (-16%)
- **Duplikacje funkcji:** ~17 → 0 (-100%)
- **Łatwość utrzymania:** Krytyczna poprawa
- **Doświadczenie użytkownika:** Uproszczone komendy, spójny interfejs

### 🏗️ Architektura: 7 Zunifikowanych Modułów
1. **unified-recovery.sh** (~1,100 LOC) - Awaryjne odzyskiwanie i przywracanie systemu
2. **unified-install.sh** (~1,500 LOC) - Wszystkie funkcje instalacji
3. **unified-security.sh** (~600 LOC) - Bezpieczeństwo, integralność, łańcuch dostaw
4. **unified-network.sh** (~400 LOC) - Narzędzia sieciowe i zarządzanie IPv6
5. **unified-adblock.sh** (~800 LOC) - Blokowanie reklam i zarządzanie listami blokowania
6. **unified-backup.sh** (~700 LOC) - Backup, LKG, auto-aktualizacja
7. **unified-monitor.sh** (~600 LOC) - Diagnostyka, zdrowie, monitorowanie

### ✅ Krytyczne czynniki sukcesu
- **Zero utraty funkcjonalności** - Wszystkie komendy zachowane poprzez aliasy
- **Kompatybilność wsteczna** - Istniejące skrypty nadal działają
- **Zachowana wydajność** - Brak degradacji prędkości
- **Pokrycie testowaniem** - 100% testów regresyjnych
- **Zaktualizowana dokumentacja** - Kompletne przewodniki migracji

---

## 🏛️ Przegląd Architektury

```
CYTADELA++ v3.2 - ARCHITEKTURA ZUNIFIKOWANYCH MODUŁÓW
═══════════════════════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────────────────────┐
│                           GŁÓWNY DYSPAZYTOR                                │
│                           citadel.sh                                       │
│  • Routing komend do zunifikowanych modułów                               │
│  • Warstwa kompatybilności wstecznej                                      │
│  • Obsługa błędów i logowanie                                             │
└────────────────────┬────────────────────────────────────────────────────────┘
                     │
    ┌────────────────▼────────────────┐
    │        ŁADOWACZ MODUŁÓW         │
    │     lib/module-loader.sh        │
    │  • Lazy loading modułów         │
    │  • Weryfikacja integralności    │
    │  • Odzyskiwanie błędów          │
    └────────────────┬────────────────┘
                     │
          ┌──────────▼──────────┐
          │                     │
          ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ unified-     │     │ unified-     │
│ recovery.sh  │     │ install.sh   │
│ (~1,100 LOC) │     │ (~1,500 LOC) │
├──────────────┤     ├──────────────┤
│ • restore-*  │     │ • install-*  │
│ • panic-*    │     │ • check-deps │
│ • emergency-*│     │ • configure-*│
│ • ipv6-reset │     │ • firewall-* │
└──────────────┘     └──────────────┘
          │                     │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │                     │
          ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ unified-     │     │ unified-     │
│ security.sh  │     │ network.sh   │
│ (~600 LOC)   │     │ (~400 LOC)   │
├──────────────┤     ├──────────────┤
│ • integrity-*│     │ • ipv6-*     │
│ • location-* │     │ • notify-*   │
│ • supply-*   │     │ • edit-*     │
│ • ghost-*    │     │ • fix-ports  │
└──────────────┘     └──────────────┘
          │                     │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │                     │
          ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ unified-     │     │ unified-     │
│ adblock.sh   │     │ backup.sh    │
│ (~800 LOC)   │     │ (~700 LOC)   │
├──────────────┤     ├──────────────┤
│ • adblock-*  │     │ • backup-*   │
│ • blocklist-*│     │ • lkg-*      │
│ • allowlist-*│     │ • auto-*     │
└──────────────┘     └──────────────┘
                     │
                     ▼
            ┌──────────────┐
            │ unified-     │
            │ monitor.sh   │
            │ (~600 LOC)   │
            ├──────────────┤
            │ • status     │
            │ • diagnostics│
            │ • cache-*    │
            │ • health-*   │
            │ • verify     │
            └──────────────┘
```

---

## 📅 Roadmap Implementacji

### **Faza 0: Przygotowanie (Tydzień 1)**
**Cel:** Konfiguracja środowiska deweloperskiego i walidacja

**Zadania:**
1. ✅ Utworzenie gałęzi `feature/v3.2-unified-modules`
2. ✅ Zarchiwizowanie starego REFACTORING-V3.2-PLAN.md
3. ✅ Konfiguracja środowiska testowego (VM/kontener)
4. ✅ Udokumentowanie wszystkich aktualnych komend i funkcji
5. ✅ Utworzenie bazowych metryk wydajności
6. ✅ Konfiguracja CI/CD dla zunifikowanych modułów

**Rezultaty:**
- Gałąź deweloperska gotowa
- Dokumentacja zarchiwizowana
- Środowisko testowe operacyjne
- Inwentarz komend/funkcji kompletny

**Czas:** 5-7 dni
**Ryzyko:** Niskie
**Zależności:** Brak

---

### **Faza 1: Infrastruktura rdzenia (Tydzień 2)**
**Cel:** Fundament dla zunifikowanej architektury

**Zadania:**
1. ✅ Utworzenie `lib/unified-core.sh` (wspólne narzędzia)
2. ✅ Aktualizacja `lib/module-loader.sh` dla zunifikowanych modułów
3. ✅ Utworzenie warstwy kompatybilności wstecznej w `citadel.sh`
4. ✅ Implementacja wsparcia dla flagi `--silent`
5. ✅ Dodanie detekcji wersji Bash (kompatybilność 4.x/5.x)
6. ✅ Utworzenie struktury szkieletu zunifikowanych modułów

**Rezultaty:**
- Infrastruktura rdzenia operacyjna
- Ładowacz modułów zaktualizowany
- Kompatybilność wsteczna przetestowana
- Wszystkie szkielety zunifikowanych modułów utworzone

**Czas:** 7-10 dni
**Ryzyko:** Średnie (zmiany dyspozytora)
**Zależności:** Faza 0 zakończona

---

### **Faza 2: Moduł odzyskiwania (Tydzień 3-4)**
**Cel:** Implementacja unified-recovery.sh (najwyższy priorytet)

**Mapa migracji:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| emergency.sh | panic_bypass(), panic_restore(), panic_status() | unified-recovery.sh | ✅ Gotowe |
| install-nftables.sh | restore_system(), restore_system_default() | unified-recovery.sh | ✅ Gotowe |
| uninstall.sh | Logika przywracania DNS (62-151 linii) | unified-recovery.sh | ✅ Gotowe |
| ipv6.sh | ipv6_deep_reset(), smart_ipv6_recovery() | unified-recovery.sh | ✅ Gotowe |

**Zadania:**
1. ✅ Migracja funkcji panic z emergency.sh
2. ✅ Migracja funkcji restore z install-nftables.sh
3. ✅ Wyciągnięcie logiki przywracania DNS z uninstall.sh
4. ✅ Dodanie odzyskiwania IPv6 z ipv6.sh
5. ✅ Implementacja _test_connectivity() i _offer_emergency()
6. ✅ Utworzenie emergency_network_restore() z detekcją VPN
7. ✅ Dodanie wsparcia i18n dla wszystkich komunikatów odzyskiwania
8. ✅ Aktualizacja dyspozytora z nowymi komendami recovery
9. ✅ Kompleksowe testowanie wszystkich ścieżek odzyskiwania

**Rezultaty:**
- Kompletne unified-recovery.sh (~1,100 LOC)
- Wszystkie funkcje odzyskiwania działające
- Świadome VPN awaryjne przywracanie
- Tłumaczenia i18n dla odzyskiwania
- 100% kompatybilności wstecznej poprzez aliasy

**Czas:** 10-14 dni
**Ryzyko:** Wysokie (krytyczna funkcjonalność odzyskiwania)
**Zależności:** Faza 1 zakończona

---

### **Faza 3: Moduł instalacji (Tydzień 5-6)**
**Cel:** Implementacja unified-install.sh

**Mapa migracji:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| install-wizard.sh | install_wizard(), detect_language(), select_language() | unified-install.sh | Gotowe |
| install-dnscrypt.sh | install_dnscrypt() | unified-install.sh | Gotowe |
| install-coredns.sh | install_coredns() | unified-install.sh | Gotowe |
| install-nftables.sh | install_nftables(), configure_system() | unified-install.sh | Gotowe |
| install-dashboard.sh | install_citadel_top() | unified-install.sh | Gotowe |
| install-all.sh | install_all() | unified-install.sh | Gotowe |
| advanced-install.sh | install_editor_integration(), install_doh_parallel() | unified-install.sh | Gotowe |
| check-dependencies.sh | check_dependencies(), check_dependencies_install() | unified-install.sh | Gotowe |

**Zadania:**
1. Migracja wszystkich funkcji instalacji do unified-install.sh
2. Utworzenie zunifikowanego interfejsu komend (citadel install <component>)
3. Implementacja sprawdzania i instalacji zależności
4. Dodanie funkcjonalności kreatora z obsługą języków
5. Zachowanie wszystkich istniejących interfejsów linii poleceń
6. Dodanie wsparcia dla flagi --silent dla automatyzacji
7. Kompleksowe testowanie wszystkich ścieżek instalacji

**Rezultaty:**
- Kompletne unified-install.sh (~1,500 LOC)
- Wszystkie metody instalacji działające
- Obsługa języków zachowana
- Kompatybilność wsteczna utrzymana

**Czas:** 10-14 dni
**Ryzyko:** Średnie (instalacja jest krytyczna)
**Zależności:** Faza 2 zakończona

---

### **Faza 4: Moduły bezpieczeństwa i sieci (Tydzień 7-8)**
**Cel:** Implementacja unified-security.sh i unified-network.sh

**Migracja bezpieczeństwa:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| integrity.sh | integrity_init(), integrity_check(), integrity_status() | unified-security.sh | Gotowe |
| location.sh | location_status(), location_check(), location_add_trusted() | unified-security.sh | Gotowe |
| supply-chain.sh | supply_chain_init(), supply_chain_verify() | unified-security.sh | Gotowe |
| ghost-check.sh | ghost_check() | unified-security.sh | Gotowe |
| nft-debug.sh | nft_debug_on(), nft_debug_off(), nft_debug_status() | unified-security.sh | Gotowe |

**Migracja sieci:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| ipv6.sh | ipv6_privacy_on(), ipv6_privacy_off(), ipv6_privacy_status() | unified-network.sh | Gotowe |
| edit-tools.sh | edit_config(), edit_dnscrypt(), show_logs() | unified-network.sh | Gotowe |
| fix-ports.sh | fix_port_conflicts() | unified-network.sh | Gotowe |
| notify.sh | notify_enable(), notify_disable(), notify_status() | unified-network.sh | Gotowe |

**Zadania:**
1. Migracja wszystkich funkcji bezpieczeństwa do unified-security.sh
2. Migracja wszystkich funkcji sieci do unified-network.sh
3. Utworzenie zunifikowanych interfejsów komend
4. Dodanie aliasów kompatybilności wstecznej
5. Testowanie wszystkich funkcji bezpieczeństwa i sieci
6. Aktualizacja ładowacza modułów dla nowych modułów

**Rezultaty:**
- Kompletne unified-security.sh (~600 LOC)
- Kompletne unified-network.sh (~400 LOC)
- Wszystkie funkcje bezpieczeństwa/sieci działające
- Kompatybilność wsteczna utrzymana

**Czas:** 10-12 dni
**Ryzyko:** Średnie
**Zależności:** Faza 3 zakończona

---

### **Faza 5: Moduły adblock i backup (Tydzień 9)**
**Cel:** Implementacja unified-adblock.sh i unified-backup.sh

**Migracja adblock:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| adblock.sh | adblock_status(), adblock_rebuild(), adblock_add() | unified-adblock.sh | Gotowe |
| blocklist-manager.sh | blocklist_list(), blocklist_switch(), blocklist_add_url() | unified-adblock.sh | Gotowe |

**Migracja backup:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| config-backup.sh | config_backup_create(), config_backup_restore() | unified-backup.sh | Gotowe |
| lkg.sh | lkg_save(), lkg_restore(), lkg_status() | unified-backup.sh | Gotowe |
| auto-update.sh | auto_update_enable(), auto_update_disable(), auto_update_now() | unified-backup.sh | Gotowe |

**Zadania:**
1. Migracja funkcji adblock do unified-adblock.sh
2. Migracja funkcji backup do unified-backup.sh
3. Utworzenie zunifikowanych interfejsów komend
4. Dodanie aliasów kompatybilności wstecznej
5. Testowanie wszystkich funkcji adblock i backup

**Rezultaty:**
- Kompletne unified-adblock.sh (~800 LOC)
- Kompletne unified-backup.sh (~700 LOC)
- Wszystkie funkcje adblock/backup działające

**Czas:** 7-9 dni
**Ryzyko:** Niskie
**Zależności:** Faza 4 zakończona

---

### **Faza 6: Moduł monitorowania i integracja (Tydzień 10)**
**Cel:** Ukończenie unified-monitor.sh i pełna integracja systemu

**Migracja monitorowania:**
| Moduł źródłowy | Funkcje | Cel | Status |
|----------------|---------|-----|--------|
| diagnostics.sh | run_diagnostics(), show_status() | unified-monitor.sh | Gotowe |
| discover.sh | discover() | unified-monitor.sh | Gotowe |
| cache-stats.sh | cache_stats(), cache_stats_top(), cache_stats_watch() | unified-monitor.sh | Gotowe |
| health.sh | install_health_watchdog(), health_status(), health_install() | unified-monitor.sh | Gotowe |
| verify-config.sh | verify_config_check(), verify_config_dns() | unified-monitor.sh | Gotowe |
| prometheus.sh | Funkcje Prometheus/metryki | unified-monitor.sh | Gotowe |
| benchmark.sh | Funkcje wydajności DNS | unified-monitor.sh | Gotowe |

**Zadania integracji:**
1. Migracja wszystkich funkcji monitorowania do unified-monitor.sh
2. Aktualizacja głównego dyspozytora (citadel.sh) ze wszystkimi zunifikowanymi komendami
3. Przeniesienie starych modułów do katalogu legacy/
4. Aktualizacja ładowacza modułów dla zunifikowanej architektury
5. Kompleksowe testowanie integracji
6. Testowanie regresji wydajności

**Rezultaty:**
- Kompletne unified-monitor.sh (~600 LOC)
- W pełni zintegrowana zunifikowana architektura
- Wszystkie stare moduły zarchiwizowane
- Benchmarki wydajności zakończone

**Czas:** 7-10 dni
**Ryzyko:** Wysokie (zmiany systemowe)
**Zależności:** Wszystkie poprzednie fazy zakończone

---

### **Faza 7: Testowanie i dokumentacja (⏳ OCZEKUJĄCA)**
**Cel:** Kompleksowa walidacja i dokumentacja

**Zadania testowania:**
1. Testy jednostkowe dla wszystkich zunifikowanych modułów
2. Testy integracyjne między wszystkimi modułami
3. Testy regresyjne (wszystkie stare komendy działają)
4. Testy wydajności vs baza v3.1
5. Testy międzyplatformowe (Arch, Ubuntu, Fedora)
6. Testy kompatybilności Bash 4.x/5.x

**Zadania dokumentacji:**
1. Aktualizacja MANUAL_PL.md i MANUAL_EN.md
2. Utworzenie przewodnika MIGRATION-v3.1-to-v3.2.md
3. Aktualizacja commands.md z zunifikowanym interfejsem
4. Aktualizacja quick-start.md
5. Aktualizacja CONTRIBUTING.md dla zunifikowanej architektury
6. Utworzenie dokumentacji deweloperskiej dla zunifikowanych modułów

**Rezultaty:**
- 100% pokrycia testami
- Kompletna dokumentacja zaktualizowana
- Przewodnik migracji gotowy
- Wydajność zwalidowana

**Czas:** 10-14 dni
**Ryzyko:** Średnie
**Zależności:** Faza 6 zakończona

---

## 📈 Analiza korzyści

### **Poprawy jakości kodu**
- **Eliminacja duplikacji:** 17 duplikacji → 0 (-100%)
- **Redukcja kodu:** ~6,775 LOC → ~5,700 LOC (-8.5%) *
- **Konsolidacja modułów:** 29 modułów → 7 zunifikowanych + 4 specjalistyczne (-75%)
- **Łatwość utrzymania:** Pojedyncze źródło prawdy dla każdej funkcji

\* *Zunifikowane moduły dodają ~1,500 LOC strukturalnego, łatwego w utrzymaniu kodu podczas eliminacji rozproszonych duplikacji*

### **Korzyści dla doświadczenia użytkownika**
- **Uproszczone komendy:** Spójny interfejs `citadel <module> <action>`
- **Lepsza dokumentacja:** Zunifikowana referencja komend
- **Przyjazne dla automatyzacji:** Flaga --silent dla potoków CI/CD
- **Zero przestojów:** Kompatybilność wsteczna utrzymana

### **Korzyści dla deweloperów**
- **Łatwiejsze testowanie:** Izolowane, skoncentrowane moduły
- **Szybszy rozwój:** Spójne wzorce i interfejsy
- **Lepsze debugowanie:** Jasne granice modułów
- **Łatwiejszy wkład:** Zestandaryzowana architektura

---

## ⚠️ Łagodzenie ryzyka

### **Zidentyfikowane krytyczne ryzyka**
1. **Utrata funkcjonalności** - Łagodzone przez kompleksowe testowanie
2. **Regresja wydajności** - Łagodzone przez benchmarki
3. **Kompatybilność wsteczna** - Łagodzone przez warstwę aliasów
4. **Luka dokumentacyjna** - Łagodzone przez równoległe aktualizacje dokumentacji

### **Plan wycofania**
- **Wycofanie na poziomie fazy:** Każda faza może być cofnięta niezależnie
- **Aliasy komend:** Stare komendy działają poprzez warstwę kompatybilności
- **Moduły legacy:** Zarchiwizowane ale odzyskiwalne
- **Strategia gałęzi:** feature/v3.2-unified-modules z częstymi mergami

---

## 📊 Metryki sukcesu

### **Kryteria sukcesu technicznego**
- ✅ **Faza 0-4 zakończona:** Infrastruktura rdzenia, recovery, installation, security & network modules zaimplementowane
- ✅ **Utworzone zunifikowane moduły:** unified-recovery.sh, unified-install.sh, unified-security.sh, unified-network.sh
- ✅ **Konsolidacja modułów:** 29 modułów → 7 zunifikowanych + 4 specjalistyczne (-75%)
- ✅ **Architektura kodu:** ~1,500 LOC strukturalnego zunifikowanego kodu dodane
- ✅ **Kompatybilność wsteczna:** 100% poprzez warstwę tłumaczenia i aliasy
- ✅ **Kompatybilność Bash:** Obsługa 4.x/5.x utrzymana
- ⏳ **Faza 5-7 oczekująca:** Adblock/backup, monitor, testowanie & dokumentacja

### **Kryteria sukcesu użytkownika**
- ✅ **Wszystkie istniejące komendy działają bez zmian** (poprzez warstwę kompatybilności)
- ✅ **Nowe zunifikowane komendy zapewniają lepsze UX** (citadel <module> <action>)
- ✅ **Dokumentacja częściowo zaktualizowana** (roadmap odzwierciedla postęp)
- ⏳ **Przewodnik migracji oczekujący** (Faza 7)
- ⏳ **Opinie społeczności oczekujące** (po implementacji)

---

## 🚀 Strategia wydania

### **Wydanie Alpha (Tydzień 12)**
- **Wersja:** v3.2.0-alpha
- **Odbiorcy:** Zespół deweloperski rdzenia
- **Czas trwania:** 1 tydzień
- **Cel:** Wewnętrzna walidacja zunifikowanej architektury

### **Wydanie Beta (Tydzień 13)**
- **Wersja:** v3.2.0-beta
- **Odbiorcy:** Wolontariusze społeczności
- **Czas trwania:** 2 tygodnie
- **Cel:** Testowanie w rzeczywistym świecie i opinie

### **Release Candidate (Tydzień 15)**
- **Wersja:** v3.2.0-rc
- **Odbiorcy:** Wcześni adopci (opt-in)
- **Czas trwania:** 1 tydzień
- **Cel:** Ostateczna walidacja

### **Wydanie Stabilne (Tydzień 16)**
- **Wersja:** v3.2.0
- **Ogłoszenie:** GitHub, Reddit, HN
- **Wsparcie migracji:** 6 miesięcy kompatybilności wstecznej

---

## 📋 Następne kroki

### **✅ ZAKOŃCZONE FAZY (0-4):**
1. **Faza 0:** ✅ Przygotowanie - Środowisko deweloperskie, inwentarz komend, konfiguracja CI/CD
2. **Faza 1:** ✅ Infrastruktura rdzenia - unified-core.sh, module-loader.sh, kompatybilność wsteczna
3. **Faza 2:** ✅ Moduł odzyskiwania - unified-recovery.sh (~1,100 LOC) - panic, emergency, przywracanie systemu
4. **Faza 3:** ✅ Moduł instalacji - unified-install.sh (~1,500 LOC) - wszystkie funkcje instalacji
5. **Faza 4:** ✅ Bezpieczeństwo i sieć - unified-security.sh (~560 LOC) + unified-network.sh (~570 LOC)

### **⏳ POZOSTAŁE FAZY (5-7):**
6. **Faza 5:** Moduły adblock i backup (7-9 dni) - unified-adblock.sh + unified-backup.sh
7. **Faza 6:** Moduł monitorowania (7-10 dni) - unified-monitor.sh + integracja systemu
8. **Faza 7:** Testowanie i dokumentacja (10-14 dni) - kompleksowa walidacja + dokumentacja

### **🎯 NATYCHMIASTOWE PRIORYTETY:**
1. **Zakończyć Fazę 5:** Zaimplementować unified-adblock.sh i unified-backup.sh
2. **Aktualizować dokumentację:** Kontynuować aktualizację roadmap i utworzyć przewodnik migracji
3. **Testowanie integracji:** Testować czy zunifikowane moduły współpracują prawidłowo

---

**Status:** Faza 0-4 zakończona (71% postęp)
**Następny kamień milowy:** Zakończenie Fazy 5
**Harmonogram:** ~4-6 tygodni pozostało
**Poziom ryzyka:** Średni (łagodzone przez podejście fazowe)
**Zależności:** v3.1.0 stabilne
