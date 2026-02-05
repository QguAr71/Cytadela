# 🚀 Przewodnik Szybkiego Startu

Uruchom Cytadelę w ciągu 5 minut!

---

## ⚡ Instalacja

### Krok 1: Klonuj Repozytorium
```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel
```

### Krok 2: Sprawdź Zależności
```bash
sudo ./citadel.sh check-deps
```

### Krok 3: Wybierz Tryb Instalacji

**Opcja A: Graficzny Kreator Instalacji (Zalecane)**
```bash
sudo ./citadel.sh setup-wizard
```
- Interaktywny GUI z whiptail
- **Auto-wykrywa** czy Cytadela jest zainstalowana
- **Tryb instalacyjny**: Pełna instalacja z checklistą
- **Tryb zarządzania**: Przeinstaluj, odinstaluj lub modyfikuj (gdy zainstalowane)
- Wsparcie 7 języków (auto-wykrywanie z $LANG): PL, EN, DE, ES, IT, FR, RU

> **Wskazówka:** Używaj `setup-wizard` zarówno dla świeżej instalacji jak i deinstalacji - automatycznie wykrywa stan systemu!

**Legacy:** `install-wizard` nadal działa tylko dla świeżej instalacji.

> **Uwaga:** Obecnie tylko **PL i EN** mają pełną dokumentację (MANUAL_PL.md, MANUAL_EN.md). Pozostałe 5 języków (DE, ES, IT, FR, RU) są dostępne tylko w interfejsie install-wizard. Kompletna i18n dla wszystkich poleceń CLI, modułów i dokumentacji jest planowana na **v3.2** (wydanie Weles-SysQ).

**Opcja B: CLI dla Hardcore Użytkowników**
```bash
sudo ./citadel.sh install-all
```
- Bez GUI - czysty CLI
- Szybka, automatyczna instalacja
- Pełna kontrola przez logi

> **Uwaga:** Dla wersji legacy (v3.0), zobacz katalog `legacy/`

### Krok 4: Skonfiguruj System (Krytyczne!)
```bash
sudo ./citadel.sh configure-system
```
- Przełącza z systemd-resolved na DNS Cytadela
- Tworzy backup oryginalnej konfiguracji
- Włącza ochronę przed wyciekami DNS

> **Ważne:** Bez tego kroku Cytadela jest zainstalowana ale nieaktywna. System nadal używa systemd-resolved.

### Krok 5: Zweryfikuj Instalację
```bash
sudo ./citadel.sh verify
```

---

## 🎯 Podstawowe Użycie

### Sprawdź Status
```bash
sudo ./citadel.sh status
```

### Testuj Rozwiązywanie DNS
```bash
sudo ./citadel.sh test
```

### Wyświetl Statystyki Adblock
```bash
sudo ./citadel.sh adblock-status
```

---

## 🔧 Najważniejsze Polecenia

```bash
# Konfiguracja Systemu
sudo ./citadel.sh configure-system    # Przełącz na DNS Cytadela
sudo ./citadel.sh firewall-strict     # Włącz ścisły firewall

# Monitorowanie
sudo ./citadel.sh health-status       # Sprawdzenie zdrowia
sudo ./citadel.sh cache-stats         # Statystyki cache

# Konserwacja
sudo ./citadel.sh auto-update-enable  # Włącz auto-aktualizacje
sudo ./citadel.sh config-backup       # Backup konfiguracji
```

---

## 🆘 Rozwiązywanie Problemów

### DNS Nie Działa?
```bash
sudo ./citadel.sh diagnostics
```

### Konflikty Portów?
```bash
sudo ./citadel.sh fix-ports
```

### Odzyskiwanie Awaryjne
```bash
sudo ./citadel.sh panic-bypass
```

---

## �️ Deinstalacja

Jeśli potrzebujesz usunąć Cytadelę:

```bash
# Kompletne usunięcie (config + dane)
sudo ./citadel.sh uninstall

# Lub zachowaj konfigurację do późniejszej reinstalacji
sudo ./citadel.sh uninstall-keep-config
```

---

## �📚 Następne Kroki

- [Pełny Manual (PL)](MANUAL_PL.md) - Kompletny polski przewodnik
- [Pełny Manual (EN)](MANUAL_EN.md) - Kompletny angielski przewodnik
- [Referencja Poleceń](commands.md) - Wszystkie dostępne polecenia
- [FAQ](FAQ.md) - Często zadawane pytania

### Wersja Legacy

Jeśli potrzebujesz wersji legacy monolitycznej (v3.0):
```bash
cd legacy/
sudo ./cytadela++.sh install-all
```
Zobacz `legacy/README.md` po szczegóły.

---

**Potrzebujesz pomocy?** Sprawdź [FAQ](FAQ.md) lub [utwórz zgłoszenie](https://github.com/QguAr71/Cytadela/issues).
