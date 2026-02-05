# Dziennik Zmian

Wszystkie znaczące zmiany w tym repozytorium będą dokumentowane w tym pliku.

## [4.0.0] - 2026-02-04

### 🎉 **Wydanie Główne: Tryb Gateway i Infrastruktura Sieciowa**

Enterprise Security Platform v4.0 przekształca Enterprise Security Platform z resolvera DNS w kompletne rozwiązanie bramy sieciowej, umożliwiając kompletne zarządzanie siecią domową/biurową.

### ✨ Dodano

#### 🚪 **Tryb Gateway - Kompletna Brama Sieciowa**
- **Pełna Brama Sieciowa** - Przekształć Enterprise Security Platform w router/bramę sieciową
  - Integracja serwera DHCP (dnsmasq)
  - Konfiguracja NAT i routingu
  - Wykrywanie i zarządzanie interfejsami sieciowymi
  - Reguły firewall dla bezpiecznego routingu
- **Zarządzanie Urządzeniami** - Monitoruj i zarządzaj wszystkimi urządzeniami sieciowymi
  - Odkrywanie i śledzenie urządzeń w czasie rzeczywistym
  - Monitorowanie i zarządzanie leasingami DHCP
  - Integracja tabeli ARP dla widoczności urządzeń
  - Statystyki sieci per-urządzenie
- **Interaktywny Kreator Gateway** - Łatwa konfiguracja dla trybu gateway
  - Automatyczne wykrywanie interfejsów sieciowych
  - Proces konfiguracji z przewodnikiem
  - Walidacja ustawień sieci
  - Jedno-polecenie aktywacja gateway
- **Usługi Gateway** - Usługi gotowe do produkcji
  - Integracja z systemd
  - Zarządzanie cyklem życia usług
  - Monitorowanie zdrowia i auto-odzyskiwanie
  - Logowanie i metryki specyficzne dla gateway

#### 🛡️ **Infrastruktura Bezpieczeństwa Sieci**
- **Zaawansowane Zarządzanie Firewall** - Reguły firewall specyficzne dla gateway
  - Automatyzacja reguł NAT
  - Zezwolenie na ruch DHCP
  - Ochrona zapytań DNS
  - Bezpieczne polityki routingu
- **Monitorowanie Sieci** - Kompleksowa widoczność sieci
  - Wyliczanie połączonych urządzeń
  - Śledzenie leasingów DHCP
  - Monitorowanie ruchu sieciowego
  - Metryki wydajności gateway

### 🔄 Zmieniono

- **Rozszerzenie Architektury** - Citadel teraz wspiera tryby dualne
  - Tryb Resolvera DNS (oryginalna funkcjonalność)
  - Tryb Gateway (nowa infrastruktura sieciowa)
- **Architektura Usług** - Ulepszone zarządzanie usługami
  - Usługi specyficzne dla gateway
  - Konfiguracja sieci multi-interfejsowej
  - Integracja DHCP z DNS

#### �️ **Zaawansowana Integracja IDS**
- **Integracja Suricata** - IDS sieciowy dla analizy ruchu DNS
  - Reguły i podpisy detekcji specyficzne dla DNS
  - Monitorowanie i alarmowanie zapytań DNS w czasie rzeczywistym
  - Detekcja DGA (Domain Generation Algorithm)
  - Detekcja tunelowania DNS i ataków amplifikacji
  - Analiza podejrzanych TLD i wzorców domen
- **Integracja Zeek** - Zaawansowana struktura analizy sieci
  - Analiza i logowanie protokołu DNS
  - Algorytmy detekcji DGA oparte na entropii
  - Detekcja i alarmowanie burz NXDOMAIN
  - Kompleksowa analiza wzorców ruchu DNS
  - Skryptowalna struktura analizy i alarmowania
- **Detekcja Zagrożeń DNS** - Zaawansowane monitorowanie bezpieczeństwa DNS
  - Detekcja i rate limiting floodu zapytań
  - Rozpoznawanie podejrzanych wzorców domen
  - Detekcja domen fast flux
  - Detekcja prób transferu strefy DNS
  - Kompleksowe logowanie zdarzeń bezpieczeństwa DNS

### 🔄 Zmieniono

- **Architektura Bezpieczeństwa** - Ulepszone możliwości detekcji zagrożeń
  - Wielowarstwowe podejście IDS z Suricata i Zeek
  - Monitorowanie i alarmowanie bezpieczeństwa specyficzne dla DNS
  - Integracja z istniejącymi systemami reputacji i blokowania
  - Zaawansowana analiza zagrożeń i wzorców

#### 🌐 **Dashboard WWW - Kompletny Interfejs Monitorowania**
- **Nowoczesny Interfejs WWW** - Responsywny dashboard HTML/CSS/JavaScript
  - Monitorowanie statusu systemu w czasie rzeczywistym i wizualizacja
  - Przegląd bezpieczeństwa z metrykami zagrożeń i alarmami
  - Zarządzanie urządzeniami sieciowymi i śledzenie leasingów DHCP
  - Alarmy IDS i monitorowanie statusu
  - Interaktywne kontrolki z możliwością auto-odświeżania
- **Integracja Serwera WWW** - Obsługa Nginx i Lighttpd
  - Automatyczna konfiguracja i deployment serwera WWW
  - Wzmocnienie bezpieczeństwa z właściwymi nagłówkami i kontrolami dostępu
  - Optymalizacja cache i kompresji plików statycznych
  - Reverse proxy dla punktów końcowych API
- **Backend API RESTful** - API JSON do pobierania danych
  - Status systemu, metryki bezpieczeństwa i informacje sieciowe
  - Aktualizacje danych w czasie rzeczywistym z automatycznym odświeżaniem
  - Obsługa błędów i raportowanie statusu
  - Rozszerzalny projekt API dla przyszłych ulepszeń
- **Doświadczenie Użytkownika** - Profesjonalny interfejs monitorowania
  - Czysty, nowoczesny design z intuicyjną nawigacją
  - Wskaźniki statusu kodowane kolorami i alarmy
  - Responsywny layout dla desktopu i urządzeń mobilnych
  - Funkcje dostępności i nawigacja klawiaturą

### 🔄 Zmieniono

- **Paradygmat Interfejsu Użytkownika** - Monitorowanie oparte na WWW obok CLI
  - Podejście dualnego interfejsu (CLI + WWW) dla różnych przypadków użycia
  - Dashboard WWW jako główny interfejs monitorowania
  - CLI utrzymane dla automatyzacji i skryptowania
  - Spójne raportowanie danych i statusu między interfejsami

### 📚 Dokumentacja

- **Przewodnik Dashboard WWW** - Kompletna dokumentacja interfejsu WWW
- **Referencja API** - Dokumentacja punktów końcowych API RESTful
- **Konfiguracja Serwera WWW** - Przewodniki konfiguracji Nginx/Lighttpd
- **Najlepsze Praktyki Bezpieczeństwa** - Wytyczne bezpieczeństwa interfejsu WWW

---

## Status Roadmap

### ✅ **Ukończone Funkcje Wysokiego Priorytetu**
- **Tryb Gateway** - Kompletna infrastruktura sieciowa
- **Integracja IDS** - Zaawansowana detekcja zagrożeń
- **Dashboard WWW** - Nowoczesny interfejs monitorowania

### 🔄 **Następne Kroki (Średni Priorytet)**
- **Ulepszone CLI** - Lepszy UX i auto-uzupełnianie
- **Polityki Per-Urządzenie** - Segmentacja sieci
- **Zaawansowana Inteligencja Zagrożeń** - Ulepszone feedy zagrożeń
- **Funkcje Zgodności** - Narzędzia audytu i zgodności

### 🔮 **Przyszłe Ulepszenia**
- **Integracja AI/ML** - Automatyczna analiza zagrożeń
- **Optymalizacja Wydajności** - Zaawansowane cache
- **Rozszerzenie Ekosystemu** - Integracje firm trzecich

---

### ✨ Dodano

#### 🔒 **Funkcje Bezpieczeństwa (v3.3.0)**
- **System Reputacji** - Dynamiczne ocenianie reputacji IP z automatycznym blokowaniem
  - Śledzenie i ocenianie reputacji w czasie rzeczywistym
  - Konfigurowalne progi i auto-blokowanie
  - Aktualizacje reputacji sterowane zdarzeniami
- **Blokowanie ASN** - Kontrola ruchu na poziomie sieci
  - Filtrowanie oparte na Autonomous System Number (ASN)
  - Integracja WHOIS dla wyszukiwań prefiksów
  - Automatyczne zarządzanie listami blokowania
- **Zaawansowane Logowanie Zdarzeń** - Strukturalne logowanie zdarzeń w formacie JSON
  - Wieloformatowe logowanie (JSON, tekst)
  - Konfigurowalne polityki retencji
  - Zaawansowane możliwości zapytań i analizy
- **System Honeypot** - Aktywna detekcja zagrożeń
  - Symulacja wielu usług (SSH, HTTP, RDP)
  - Logowanie i analiza połączeń
  - Automatyczne blokowanie atakujących

#### 🎯 **Funkcje Zarządzania**
- **Zarządzanie Konfiguracją YAML** - Konfiguracja oparta na profilach
  - Wielokrotne profile konfiguracji (standard, security, enterprise)
  - Walidacja konfiguracji w czasie rzeczywistym
  - Możliwości importu/eksportu i porównania
- **Dynamiczne Zarządzanie Modułami** - Kontrola modułów w czasie rzeczywistym
  - Ładowanie/wyładowywanie modułów bez restartu
  - Rozwiązywanie zależności i detekcja konfliktów
  - Odkrywanie modułów i monitorowanie statusu
- **Integracja z Systemd** - Zarządzanie usługami gotowe do produkcji
  - Automatyczne generowanie plików usług
  - Zarządzanie cyklem życia usług (start/stop/restart/enable/disable)
  - Monitorowanie zdrowia i auto-odzyskiwanie

#### 🏢 **Funkcje Zaawansowane**
- **Integracja Prometheus/Grafana** - Zaawansowane monitorowanie i wizualizacja
  - Zbieranie metryk w czasie rzeczywistym
  - Pre-konfigurowane dashboardy
  - Niestandardowe punkty końcowe metryk
- **Integracja Docker** - Deployment konteneryzowany
  - Orkiestracja docker-compose
  - Zarządzanie kontenerami multi-service
  - Konfiguracje kontenerów gotowe do produkcji
- **Zaawansowane Bezpieczeństwo** - Funkcje bezpieczeństwa klasy korporacyjnej
  - Zaawansowane reguły firewall (bazowane na nftables)
  - Integracja feedów inteligencji zagrożeń
  - Funkcje logowania audytu i zgodności
- **Funkcje Skalowalności** - Wysoka dostępność i load balancing
  - Load balancing HAProxy
  - Wysoka dostępność Keepalived
  - Monitorowanie i optymalizacja wydajności

#### 🎨 **Interfejs Użytkownika**
- **Ulepszony Instalator CLI** - Zaawansowane opcje instalacji
  - Wybór komponentów oparty na profilach
  - Tryby dry-run i verbose
  - Kompleksowe sprawdzanie zależności
- **Dashboard TUI Gum** - Interaktywny interfejs terminala
  - Monitorowanie systemu w czasie rzeczywistym
  - Przegląd statusu bezpieczeństwa
  - Interfejs zarządzania konfiguracją

### 🔄 Zmieniono

- **Przebudowa Architektury** - Kompletny redesign systemu
  - Modularna architektura z zunifikowanymi modułami
  - Projekt systemu sterowany zdarzeniami
  - Rozszerzalność oparta na wtyczkach
- **System Konfiguracji** - Migracja do konfiguracji bazowanej na YAML
  - Zachowana kompatybilność wsteczna
  - Zarządzanie konfiguracją oparte na profilach
  - Walidacja i sprawdzanie błędów w czasie rzeczywistym

### 🐛 Naprawiono

- **Zarządzanie Pamięcią** - Ulepszone wykorzystanie zasobów
- **Obsługa Błędów** - Ulepszone raportowanie błędów i odzyskiwanie
- **Wydajność** - Zoptymalizowane ładowanie i wykonywanie modułów

### 📚 Dokumentacja

- **Kompletny Zestaw Dokumentacji** - Kompleksowa dokumentacja użytkownika i dewelopera
- **Dokumentacja API** - Szczegółowa referencja modułów i API
- **Przewodnik Rozwiązywania Problemów** - Częste problemy i rozwiązania
- **Przewodnik Dewelopera** - Wytyczne architektury i współtworzenia

---

### 🌍 Internacjonalizacja Zakończona
- **Pełne wsparcie i18n dla wszystkich 30+ modułów** - Każdy moduł teraz używa zmiennych T_*
- **7 języków w pełni wspieranych:** Polski, Angielski, Niemiecki, Hiszpański, Włoski, Francuski, Rosyjski
- **Pokrycie tłumaczeń:**
  - ✅ install-wizard (wszystkie 7 języków)
  - ✅ uninstall (wszystkie 7 języków)
  - ✅ check-dependencies (wszystkie 7 języków)
  - ✅ verify-config (wszystkie 7 języków)
  - Wszystkie widoczne dla użytkownika stringi używają wzorca `${T_VAR:-fallback}`

### ✨ Nowy Moduł: verify-config
- **Cel:** Weryfikuj konfigurację Citadel, usługi i funkcjonalność DNS
- **Polecenia:**
  - `verify-config` - Pełne sprawdzenie konfiguracji
  - `verify-config dns` - Tylko testy rozwiązywania DNS
  - `verify-config services` - Tylko status usług
  - `verify-config files` - Tylko pliki konfiguracyjne
  - `verify-config all` - Wszystkie sprawdzenia włącznie z DNS
- **Funkcje:**
  - Walidacja konfiguracji CoreDNS
  - Walidacja konfiguracji DNSCrypt
  - Weryfikacja tabel NFTables
  - Status usług (coredns, dnscrypt-proxy)
  - Testy rozwiązywania DNS
  - Sprawdzenie walidacji DNSSEC

### 📦 Ulepszenia Instalacji Zależności
- **Fallback AUR dla Arch Linux:**
  - Auto-wykrywanie helperów yay/paru
  - Pytanie użytkownika przed próbą AUR
  - Pokazywanie instrukcji manualnych jeśli brak helpera
- **Instalacja per-pakiet:**
  - Kontynuacja do następnego pakietu przy niepowodzeniu
  - Indywidualne śledzenie sukcesu/niepowodzenia
  - Podsumowanie z listami zainstalowanych/niepowodzonych/AUR
- **Informacje o źródłach alternatywnych:**
  - Debian/Ubuntu: Sugestie PPA
  - Fedora/RHEL: Sugestie EPEL, RPM Fusion, COPR

### 📚 Aktualizacje Dokumentacji
- **Nowy workflow:** `.windsurf/workflows/add-new-module.md`
  - Przewodnik krok-po-kroku tworzenia modułów z i18n
  - Szablony i przykłady
  - Lista wymagań do sprawdzenia
- **Zaktualizowane commands.md:** Dodano dokumentację verify-config
- **Zaktualizowane README.md:** Oznaczono i18n jako zakończone dla wszystkich modułów

### 📊 Statystyki
- **Commitów:** 5 commitów
- **Zmienionych plików:** 15 plików
- **Nowy moduł:** 1 (verify-config)
- **Dodanych stringów tłumaczeń:** 322 (46 per język × 7 języków)
- **Dodanych linii:** ~1,500

---

## [3.1.1] - 2026-02-01 - WYDANIE KONSERWACYJNE

### 🎉 Wszystkie Elementy TODO Ukończone
- **ShellCheck:** Zero ostrzeżeń w całym kodzie (43 pliki)
- **Bezpieczeństwo:** Rate limiting, walidacja wejścia, audyt credentials
- **Testowanie:** Kompleksowe testy smoke + zestaw BATS (47 przypadków testowych)
- **Dokumentacja:** Kompletne docstringi, przykłady, ulepszenie README
- **Internacjonalizacja:** Funkcje v3.2+ w 7 językach
- **Jakość Kodu:** Formatowanie shfmt, komunikaty błędów, wskaźniki postępu

### 🔧 Ulepszenia Jakości Kodu
- **Poprawki ShellCheck:** Naprawione ostrzeżenia SC2034 w 14 modułach
- **Formatowanie Kodu:** Zastosowane shfmt do wszystkich skryptów shell (4 spacje, indentacja case)
- **Komunikaty Błędów:** Ulepszone z przykładami użycia i lepszymi opisami
- **Wskaźniki Postępu:** Dodane animowane spinner dla długich operacji

### 📚 Ulepszenia Dokumentacji
- **Dokumentacja Funkcji:** Dodano kompleksowe docstringi do 10 krytycznych funkcji
- **Skrypty Przykładów:** Utworzone 3 skrypty setup/recovery z obsługą błędów
- **Aktualizacja README:** Ulepszone z badges, podglądem dashboard, tabelą porównania, szybkimi linkami
- **Testy BATS:** Kompletny zestaw testów z testami jednostkowymi i integracyjnymi

### 🌍 Internacjonalizacja
- **Funkcje Zaawansowane:** Dodano tłumaczenia funkcji v3.2+ w DE, FR, ES, IT, RU
- **Spójność:** Zunifikowane wzorce tłumaczeń we wszystkich językach
- **Pokrycie:** Honeypot włączony, System Reputacji aktywny, Blokowanie ASN skonfigurowane

### 🛡️ Ulepszenia Bezpieczeństwa
- **Rate Limiting:** Zaimplementowane dla panic-bypass (3 próby per 60s)
- **Walidacja Wejścia:** Zweryfikowana właściwa walidacja domen w funkcjach adblock
- **Audyt Credentials:** Potwierdzono brak zakodowanych sekretów (tylko klucze publiczne)
- **Użycie Eval:** Zweryfikowano brak użycia eval w kodzie

### 🧪 Infrastruktura Testowania
- **Testy Smoke:** Dodane testy dla help, version, root check, status, check-deps
- **Zestaw BATS:** 47 przypadków testowych pokrywających loader modułów, utils sieciowe, instalację
- **Helpery Testowe:** 20+ funkcji narzędziowych dla automatyzacji testowania
- **Gotowe do CI:** Testy zaprojektowane dla środowisk continuous integration

### 🎨 Doświadczenie Użytkownika
- **Tekst Pomocy:** Restrukturyzowany z emoji i lepszą organizacją
- **Wyjście Status:** Ulepszone z kodowaniem kolorów i dodatkowymi sekcjami
- **Obsługa Błędów:** Bardziej opisowe komunikaty z przykładami
- **Sprzężenie Zwrotne Postępu:** Wizualne wskaźniki dla długotrwałych operacji

### 📊 Statystyki
- **Commitów:** 7 commitów w tym wydaniu
- **Zmienionych plików:** 60 plików
- **Dodanych linii:** 3,125
- **Usuniętych linii:** 849
- **Netto zmiana:** +2,276 linii
- **Pokrycie testami:** 47 przypadków BATS + 5 testów smoke

---

## [3.1.2] - 2026-02-01 - WYDANIE KONSERWACYJNE

### Krytyczne Poprawki Błędów
- Naprawiono `coredns-blocklist.timer` nieistniejącą jednostkę powodującą niepowodzenie install-all
- Naprawiono niezgodność klucza modułu `install-wizard` (supply-chain, nft-debug ze spacjami)
- Naprawiono liczbę modułów w dokumentacji (32 → 29 aktualnych modułów)

### Jakość Kodu (Recenzja Copilot)
- Dodano `set -o errtrace` dla propagacji ERR trap w funkcjach
- Dodano wczesne sprawdzenia fail dla istnienia katalogów lib/modules
- Ulepszono `call_fn` z walidacją pustych argumentów
- Zastąpiono raw `source` przez `source_lib` w module-loader
- Ulepszono `load_module_for_command` z dokładnym dopasowaniem przed prefiksem
- Dodano detekcję TTY aby wyłączyć kolory gdy nie TTY (CI/logi)
- Przekonwertowano funkcje log na używanie `printf` zamiast `echo -e`
- Dodano file locking (flock) do rate_limit_check dla bezpieczeństwa wątków

### Infrastruktura CI/CD
- **NOWY:** Kompleksowy workflow CI (`ci-improved.yml`)
  - Osobne joby: shellcheck, smoke-tests, bats-tests, integration
  - Kontener Arch Linux dla testów integracyjnych
  - Właściwe zachowanie fail-fast (usunięte nadmierne || true)
  - Współbieżność z cancel-in-progress
  - Cache dla pakietów apt, binarnego shfmt
- **NOWY:** Workflow sprawdzania formatu (`format-check.yml`)
  - Cache binarnego shfmt
  - Walidacja formatowania kodu
- **NOWY:** Workflow wydania (`release.yml`)
  - Automatyczne wydania GitHub przy push tag
  - Auto-generowany changelog z historii git
  - Artefakty wydania (.tar.gz + checksumy SHA256)
- **NOWY:** Listy pakietów dla kluczy cache

### Dokumentacja
- **NOWY:** Instrukcje wydania (`docs/RELEASE-INSTRUCTIONS.md`)
- **NOWY:** Sekcja zarządzania wersjami w README
- **NOWY:** Sekcja testowania z instrukcjami testowania lokalnego
- **ZAKTUALIZOWANE:** Naprawiona CITADEL-STRUCTURE.md liczba modułów i diagramy
- **ZAKTUALIZOWANE:** Dodany badge CI ShellCheck do README

### Metryki i Monitorowanie
- **NOWY:** Moduł eksportu metryk Prometheus (`modules/prometheus.sh`)
  - Status usług, rozwiązywanie DNS, metryki cache
  - Statystyki blocklist, status firewall, obciążenie systemu
  - Serwer metryk HTTP na porcie 9100
- **NOWY:** Szablon dashboard Grafana (`docs/grafana-dashboard.json`)
  - 8 paneli: usługi, cache, zapytania DNS, blocklist, firewall, obciążenie, wersja
- **NOWY:** Moduł benchmarków wydajności (`modules/benchmark.sh`)
  - Testowanie wydajności DNS (dnsperf)
  - Testy współczynnika trafień cache
  - Wydajność wyszukiwania blocklist
  - Kompleksowy zestaw benchmarków
  - Śledzenie historyczne i porównanie

### Pakowanie i Dystrybucja
- **NOWY:** Obraz Docker (`Dockerfile`)
  - Bazowany na Arch Linux dla maksymalnej kompatybilności
  - Multi-service compose z opcjonalnym Prometheus/Grafana
  - Health checks i persistent volumes
  - Host networking dla optymalnej wydajności DNS
- **NOWY:** Docker Compose (`docker-compose.yml`)
  - Profil podstawowej usługi DNS
  - Profil monitorowania z Prometheus + Grafana
  - Persistent volumes dla konfiguracji i danych
- **NOWY:** Pakiet AUR (`PKGBUILD`)
  - Obsługa pakietów Arch Linux
  - Automatyczne rozwiązywanie zależności
  - Gotowe do integracji z systemd
- **NOWY:** Dokumentacja Docker (`docs/DOCKER.md`)
  - Przewodnik szybkiego startu
  - Instrukcje deploymentu
  - Referencja volumes i portów

### Statystyki
- **Commitów:** 14 w tym wydaniu
- **Zmienionych plików:** 80
- **Dodanych linii:** +4,800
- **Usuniętych linii:** -1,200
- **Netto zmiana:** +3,600 linii

---

## [3.1.0] - 2026-01-31 - STABILNE

### Główne Zmiany

#### Reorganizacja Repozytorium
- Reorganizowana struktura repozytorium z profesjonalnym layoutem
- Utworzony katalog `docs/` (user, developer, roadmap, comparison)
- Utworzony katalog `legacy/` dla monolitycznych skryptów v3.0
- Utworzony katalog `tests/` dla wszystkich plików testowych
- Zmienione nazwy głównych skryptów: `cytadela++.new.sh` → `citadel.sh`
- Usunięte 9 przestarzałych plików

#### Dokumentacja
- **NOWY:** Kompletny polski manual (MANUAL_PL.md, 1,621 linii)
- **NOWY:** Kompletny angielski manual (MANUAL_EN.md)
- **NOWY:** Dokumentacja wsparcia 7 języków (PL, EN, DE, ES, IT, FR, RU)
- **NOWY:** Dokumentacja graficznego instalatora (install-wizard)
- **NOWY:** Dokumentacja architektury (CITADEL-STRUCTURE.md z diagramami Mermaid)
- **NOWY:** Mapa logiki modułów (MODULES-LOGIC-MAP.md)
- **NOWY:** Plany refaktoryzacji dla v3.2:
  - Propozycja zunifikowanego interfejsu (REFACTORING-UNIFIED-INTERFACE.md)
  - Analiza duplikacji funkcji (FUNCTION-DUPLICATION-ANALYSIS.md)
  - Analiza łącznych korzyści (REFACTORING-TOTAL-BENEFITS.md)
- Zaktualizowane README.md ze statusem v3.1.0 STABLE i v3.2.0 PLANNED
- Zaktualizowane quick-start.md z trybami instalacji i info legacy

#### Aktualizacje Roadmap
- Zaktualizowany roadmap z planami v3.2-v3.5+
- Utworzone 3 nowe Issues dla v3.3:
  - Issue #26: Kontrola Rodzicielska
  - Issue #27: Pełne Auto-aktualizacje
  - Issue #28: Pełne Backup/Restore
- Przeniesione Issues #19-24 do odległej przyszłości (v3.5+)

#### Nowe Moduły
- `modules/fix-ports.sh` - Rozwiązywanie konfliktów portów
- `modules/edit-tools.sh` - Narzędzia edycji konfiguracji
- `modules/install-dashboard.sh` - Terminal dashboard
- `modules/advanced-install.sh` - Optymalizacja kernela, równoległy DoH
- `modules/test-tools.sh` - Bezpieczny test, test DNS

#### Poprawki Błędów
- Naprawione aliasy modułów: `smart_ipv6()`, `killswitch_on()`, `killswitch_off()`
- Zaktualizowane workflow GitHub Actions (shellcheck.yml, smoke-tests.yml)
- Zaktualizowane ścieżki do nowych nazw plików i katalogu legacy/

#### Tryby Instalacji
- **Opcja A:** Graficzny kreator (`install-wizard`) - 7 języków, interaktywny
- **Opcja B:** CLI dla hardcore użytkowników (`install-all`) - szybki, bez GUI
- Oba tryby w pełni udokumentowane w manualach i quick-start

### Plany Refaktoryzacji (v3.2)

Na podstawie obserwacji użytkownika o chaosie w interfejsie i duplikacji funkcji:
- **Zunifikowany interfejs modułów:** 29 → 6 modułów (-79%)
- **Deduplikacja funkcji:** 17 duplikacji → 0 (-100%)
- **Całkowita redukcja kodu:** ~8,000 → ~4,800 linii (-40%)
- **Redukcja komend:** 101 → ~30 (-70%)
- **Redukcja kroków użytkownika:** 4.5 → 1 średnio (-78%)

### Statystyki
- 53 pliki zmienione
- +7,787 linii dodanych
- -3,389 linii usuniętych
- 18 plików przeniesionych do docs/
- 6 plików przeniesionych do legacy/
- 5 testów przeniesionych do tests/

### Podziękowania
- Obserwacje użytkownika o chaosie w interfejsie i duplikacji funkcji zainspirowały plany refaktoryzacji v3.2

### Najnowsze Aktualizacje (2026-01-31 Wieczór)

#### Ulepszenia Jakości Kodu
- **Refaktoryzowany citadel.sh:** Dodany helper `call_fn()` dla DRY dynamicznych wywołań funkcji
- **Bezpieczne source:** Dodany `source_lib()` z walidacją istnienia plików
- **Przenośność:** Dodany fallback realpath dla systemów bez realpath
- **Poprawki błędów:** Naprawiony błąd parametru check-deps (${2:-} → ${1:-} po shift)
- **Defensive coding:** Dodane defensive expansions (${EUID:-}, ${CYTADELA_MODE:-})
- **Kody wyjścia:** Udokumentowane kody wyjścia (0-4+)
- **ShellCheck:** 0 błędów, ulepszona zgodność

#### CI/CD i Testowanie
- **GitHub Actions:** Dodany kompleksowy workflow lint-and-test
  - ShellCheck (citadel.sh, lib/, modules/)
  - Sprawdzanie formatu shfmt
  - Testy BATS (gdy dostępne)
  - Sprawdzania bezpieczeństwa (zakodowane sekrety, strict mode)
- **ShellCheckRC:** Ulepszona konfiguracja z przykładami inline annotation
- **Usunięty CodeQL:** Bash nie wspierany, używany ShellCheck zamiast

#### Dokumentacja
- **Naprawione placeholders:** Poprawione 15 wystąpień yourusername → QguAr71/Cytadela
- **Plany refaktoryzacji:**
  - v3.2: Funkcje Bash 5.0+, tablice asocjacyjne, flaga --silent
  - v3.3: Dodana funkcja Honeypot
  - v3.4: Plan Web Dashboard (2-3 tygodnie, htmx+Bash, HTTPS)
- **Aurora Mystica:** Oznaczona jako IS-ONLY-A-CONCEPT

#### Przyszłe Branding
- **Uwaga:** Projekt zostanie rebrandowany na "Weles-SysQ" w wydaniu v3.2
- **Uzasadnienie:** Weles - Słowiański bóg magii, przysiąg i strażnik bogactwa/prosperity
  - Doskonała metafora: DNS jako strażnik/broniący bramki internetowej
  - Unikalna mitologia słowiańska (korzenie polskie)
  - Brak konfliktów z istniejącym oprogramowaniem DNS
  - Łatwe wymawianie i zapadająca w pamięć nazwa

---

## Nieopublikowane

- Dodaj fail-fast sprawdzenia zależności w modułach install.
- Dodaj opcjonalny toggle DNSSEC dla generowanej konfiguracji DNSCrypt (`CITADELA_DNSSEC=1` lub `--dnssec`).
- Spraw aby moduły helper Arch/CachyOS-specific degradowały się elegancko gdy brakuje `pacman`/`yay`.
- Obniż agresywność tuningu priorytetu w `optimize-kernel`.

## 2026-01-23

- Spraw aby instalacja CoreDNS była odporna gdy zmienia się port DNSCrypt (bootstrap CoreDNS forward do aktualnego portu podczas downloads).
- Dodaj panel DNS adblock (`adblock-*`) i hardened parsowanie blocklist + atomic updates.
- Napraw użycie hosts CoreDNS poprzez łączenie custom + blocklist w pojedynczy `combined.hosts`.
- Napraw uprawnienia pliku hosts CoreDNS dla `User=coredns`.
- Dodaj healthcheck `install-all` (DNS + adblock).
- Dodaj dwujęzyczne docs (`README.md`, notatki PL/EN) i angielski entrypoint skryptu (`citadela_en.sh`).
- Spraw aby instalacja nftables była idempotent (flush tables + dedupe include line).
- Zaktualizuj docs: rekomenduj `verify` + leak test po aktualizacjach.
