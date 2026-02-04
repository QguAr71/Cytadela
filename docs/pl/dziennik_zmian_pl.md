# Dziennik zmian

Wszystkie znaczące zmiany w Citadel będą dokumentowane w tym pliku.

Format jest oparty na [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
a projekt jest zgodny z [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.3.0] - 2026-02-04

### 🎉 **Główna wersja: Platforma bezpieczeństwa korporacyjnego**

Citadel v3.3 przekształca Citadel z platformy skoncentrowanej na DNS w kompleksową platformę bezpieczeństwa klasy enterprise z zaawansowanym wykrywaniem zagrożeń, zarządzaniem i monitorowaniem.

### ✨ Dodano

#### 🔒 **Funkcje bezpieczeństwa (v3.3.0)**
- **System reputacji** - Dynamiczne punktowanie reputacji IP z automatycznym blokowaniem
  - Czas rzeczywisty tracking i punktowanie reputacji
  - Konfigurowalne progi i auto-blokowanie
  - Zdarzeniowe aktualizacje reputacji
- **Blokowanie ASN** - Kontrola ruchu na poziomie sieci
  - Filtrowanie oparte na Autonomous System Numbers
  - Integracja z WHOIS dla lookup'ów prefiksów
  - Automatyczne zarządzanie listami blokowania
- **Zaawansowane logowanie zdarzeń** - Strukturalne logowanie zdarzeń w formacie JSON
  - Wieloformatowe logowanie (JSON, tekst)
  - Konfigurowalne polityki retencji
  - Zaawansowane możliwości przeszukiwania i analizy
- **System Honeypot** - Aktywne wykrywanie zagrożeń
  - Symulacja wielu usług (SSH, HTTP, RDP)
  - Logowanie połączeń i analiza
  - Automatyczne blokowanie atakujących

#### 🎯 **Funkcje zarządzania**
- **Zarządzanie konfiguracją YAML** - Konfiguracja oparta na profilach
  - Wielokrotne profile konfiguracyjne (standard, security, enterprise)
  - Walidacja konfiguracji w czasie wykonania
  - Możliwości importu/eksportu i porównania
- **Dynamiczne zarządzanie modułami** - Kontrola modułów w czasie wykonania
  - Ładowanie/wyładowywanie modułów bez restartu
  - Rozdzielczość zależności i wykrywanie konfliktów
  - Odkrywanie modułów i monitorowanie statusu
- **Integracja usług systemd** - Zarządzanie usługami gotowe do produkcji
  - Automatyczne generowanie plików usług
  - Zarządzanie cyklem życia usług (start/stop/restart/enable/disable)
  - Monitorowanie zdrowia i auto-odzyskiwanie

#### 🏢 **Funkcje korporacyjne**
- **Integracja Prometheus/Grafana** - Zaawansowane monitorowanie i wizualizacja
  - Kolekcja metryk w czasie rzeczywistym
  - Pre-konfigurowane dashboard'y
  - Niestandardowe endpoint'y metryk
- **Integracja Docker** - Wdrożenia konteneryzowane
  - Orkiestracja docker-compose
  - Wielo-serwisowe zarządzanie kontenerami
  - Konfiguracje kontenerów gotowe do produkcji
- **Bezpieczeństwo korporacyjne** - Funkcje bezpieczeństwa klasy korporacyjnej
  - Zaawansowane reguły firewall (oparte na nftables)
  - Integracja kanałów threat intelligence
  - Logowanie audytu i zgodności
- **Funkcje skalowalności** - Wysoka dostępność i load balancing
  - Load balancing HAProxy
  - Wysoka dostępność Keepalived
  - Monitorowanie wydajności i optymalizacja

#### 🎨 **Interfejs użytkownika**
- **Ulepszony instalator CLI** - Zaawansowane opcje instalacji
  - Wybór komponentów oparty na profilach
  - Tryby dry-run i verbose
  - Kompleksowe sprawdzanie zależności
- **Dashboard TUI Gum** - Interaktywny interfejs terminalowy
  - Monitorowanie systemu w czasie rzeczywistym
  - Przegląd statusu bezpieczeństwa
  - Interfejs zarządzania konfiguracją

### 🔄 Zmieniono

- **Przeprojektowanie architektury** - Kompletna przebudowa systemu
  - Modularna architektura z zunifikowanymi modułami
  - Projekt oparty na zdarzeniach
  - Rozszerzalność oparta na plugin'ach
- **System konfiguracji** - Migracja do konfiguracji opartej na YAML
  - Zachowana kompatybilność wsteczna
  - Zarządzanie konfiguracją opartą na profilach
  - Walidacja błędów i sprawdzanie w czasie wykonania

### 🐛 Naprawiono

- **Zarządzanie pamięcią** - Ulepszone wykorzystanie zasobów
- **Obsługa błędów** - Ulepszone raportowanie błędów i odzyskiwanie
- **Wydajność** - Zoptymalizowane ładowanie i wykonywanie modułów

### 📚 Dokumentacja

- **Kompletny pakiet dokumentacyjny** - Kompleksowa dokumentacja użytkownika i programisty
- **Dokumentacja API** - Szczegółowa referencja modułów i API
- **Przewodnik rozwiązywania problemów** - Najczęstsze problemy i rozwiązania
- **Przewodnik programisty** - Architektura i wytyczne dotyczące wkładu

---

## [3.2.0] - 2026-XX-XX (Planowane)

### ✨ Dodano
- **Tryb Gateway** - Funkcjonalność gateway sieci
- **Terminal UI (TUI)** - Interfejs oparty na ncurses
- **Serwer DHCP** - Zintegrowane zarządzanie DHCP
- **Zarządzanie per-urządzeniem** - Indywidualne polityki urządzeń

---

## [3.1.1] - 2026-02-02

### ✨ Dodano
- **32 Funkcjonalne moduły** - Kompletny system modułów z lazy loading
- **7 języków wsparcia** - Pełna internacjonalizacja (PL, EN, DE, ES, IT, FR, RU)
- **Interaktywny instalator** - Kreator oparty na whiptail
- **Dashboard terminalowy** - Monitorowanie w czasie rzeczywistym z `citadel-top`
- **System auto-aktualizacji** - Timer systemd + fallback LKG
- **Powiadomienia desktop** - Powiadomienia o statusie systemu
- **Wsparcie multi-blocklist** - Integracja StevenBlack + OISD

### 🔄 Zmieniono
- **Struktura repozytorium** - Profesjonalna organizacja
- **Pipeline CI/CD** - Ulepszone testowanie i walidacja
- **Optymalizacje wydajności** - Ulepszone cachowanie i czasy odpowiedzi

### 🐛 Naprawiono
- **Prywatność IPv6** - Zarządzanie tymczasowymi adresami
- **Wycieki pamięci** - Ulepszenia zarządzania zasobami
- **Problemy ze stabilnością** - Ulepszona obsługa błędów

---

## [3.0.0] - 2026-01-25

### 🎉 **Główna wersja: Gotowe do produkcji**

Początkowa stabilna wersja z podstawowymi funkcjami infrastruktury DNS.

### ✨ Dodano
- **Integracja DNSCrypt-Proxy** - Zaszyfrowane zapytania DNS (DoH/DoT/DNSCrypt)
- **Backend CoreDNS** - Wysokowydajny resolver buforujący
- **Firewall NFTables** - Ochrona przed wyciekiem DNS
- **Blokowanie reklam** - Blokowanie 325,000+ domen
- **Metryki Prometheus** - Monitorowanie w czasie rzeczywistym
- **Ochrona łańcucha dostaw** - Weryfikacja integralności
- **Prywatność IPv6** - Zarządzanie tymczasowymi adresami
- **Odzyskiwanie awaryjne** - Tryb bypass paniki
- **Architektura modularna** - 30+ niezależnych modułów
- **Auto-aktualizacja** - Aktualizacje blocklist
- **Wielojęzyczność** - 7 języków (PL, EN, DE, ES, IT, FR, RU)
- **Instalator interaktywny** - Graficzny kreator (whiptail)

### 📚 Dokumentacja
- **Kompletny manual polski** - Przewodnik polski (1,621 linii)
- **Kompletny manual angielski** - Przewodnik angielski
- **Dokumentacja 7 języków** - Wsparcie dla wszystkich języków
- **Dokumentacja instalatora** - Szczegółowe instrukcje instalacji
- **Dokumentacja architektury** - Diagramy w Mermaid
- **Mapa logiki modułów** - Szczegółowa mapa modułów

---

## [2.x] - 2025-XX-XX (Starsze wersje)

Starsze wersje skoncentrowane na infrastrukturze DNS. Zobacz katalog `legacy/` dla historycznych wydań.

---

## 📋 Numeracja wersji

Citadel używa [Semantic Versioning](https://semver.org/):

- **MAJOR** wersja dla niekompatybilnych zmian API
- **MINOR** wersja dla dodawania funkcjonalności wstecznie kompatybilnej
- **PATCH** wersja dla wstecznie kompatybilnych poprawek błędów

### Kanały wydań

- **Stabilne** - Wydania gotowe do produkcji (parzyste wersje minor)
- **Beta** - Wydania kompletne funkcjonalnie wymagające testowania
- **Alpha** - Wczesne wydania z niekompletnymi funkcjami

### Polityka wsparcia

- **Najnowsze stabilne wydanie** - Pełne wsparcie
- **Poprzednie stabilne wydanie** - Aktualizacje bezpieczeństwa tylko
- **Wersje legacy (< 3.0)** - Wsparcie społeczności tylko

---

## 🎯 Przyszła roadmapa

### v3.4.0 (Q2 2026)
- **Integracja AI/ML** - Wykrywanie zagrożeń oparte na uczeniu maszynowym
- **Architektura Zero Trust** - Kontrola dostępu oparta na tożsamości
- **Integracja chmury** - Wsparcie dla wielochmurowych wdrożeń

### v4.0.0 (2027)
- **Architektura mikrousług** - Kompletna przebudowa systemu
- **Integracja Kubernetes** - Orkiestracja kontenerów
- **Zaawansowana analityka** - Big data analityka bezpieczeństwa

---

## 🤝 Wkład

Zobacz [CONTRIBUTING.md](docs/developer/contributing.md) po wytyczne dotyczące wkładu.

### Proces wydania

1. **Rozwój funkcji** - Implementacja funkcji w branch'ach funkcji
2. **Testowanie** - Kompleksowe testowanie i walidacja
3. **Dokumentacja** - Aktualizacja całej dokumentacji
4. **Wydanie** - Utworzenie wydania GitHub z changelog
5. **Wdrożenie** - Automatyczne wdrożenie do repozytoriów
6. **Wsparcie** - Monitorowanie i rozwiązywanie problemów

### Konwencja commit'ów

```
typ(zakres): opis

Typy:
- feat: Nowe funkcje
- fix: Poprawki błędów
- docs: Zmiany dokumentacji
- style: Zmiany stylu kodu
- refactor: Refaktoryzacja kodu
- test: Zmiany testów
- chore: Zadania konserwacyjne
```

---

## 📞 Wsparcie

- **📧 Email:** [GitHub Issues](https://github.com/QguAr71/Cytadela/issues)
- **💬 Dyskusje:** [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)
- **📖 Dokumentacja:** [docs/](docs/)

---

*Dla starszych wersji zobacz katalog `legacy/` lub historyczne wydania.*
