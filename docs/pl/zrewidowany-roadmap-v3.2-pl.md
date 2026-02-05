# Zrewidowany Roadmap Cytadela v3.2+

**Data:** 2026-02-01
**Status:** WERSJA ROBOCZA - Recenzja Wewnętrzna
**Zastępuje:** REFACTORING-V3.2-PLAN.md

---

## Opis Problemu

Istniejący plan v3.2 (`REFACTORING-V3.2-PLAN.md`) został napisany **przed** ukończeniem v3.1 i zawiera:
- **Przestarzałe założenia** (plany utworzenia `lib/cytadela-core.sh`, które już istnieje w v3.1)
- **Konfliktowy zakres** (refaktoryzacja 29→6 modułów vs funkcja Gateway Mode)
- **Nierealistyczny harmonogram** (3-4 tygodnie na refaktoryzację 150KB + testy + dokumentacja)

---

## Decyzja: Podejście Hybrydowe (Zalecane)

### Filozofia
- **Nie psuj działającej architektury** - modularny projekt v3.1 jest solidny
- **Stopniowa poprawa** zamiast rewolucyjnego przepisania
- **Wartość dla użytkownika na pierwszym miejscu** - funkcje przed refaktoryzacją

---

## Zrewidowany Harmonogram

### v3.2 (Q1 2026) - Fokus na Gateway
**Cel:** Tryb Gateway Sieciowej dla użytkowników domowych

**Funkcje:**
1. **Tryb Gateway** (PRIORYTET #1)
   - Serwer DHCP (dnsmasq)
   - NAT i routing (nftables)
   - Statystyki per-urządzenie
   - Polecenia: `gateway-wizard`, `gateway-status`, `gateway-devices`
   - **Nakład pracy:** ~20-25h

2. **Terminal UI (TUI)**
   - Dashboard ncurses
   - Działa przez SSH
   - Polecenia: `tui-start`, `tui-status`
   - **Nakład pracy:** ~10-12h

3. **Poprawki błędów z v3.1**
   - Kontynuacja naprawiania przypadków brzegowych
   - **Nakład pracy:** ~5h

**Razem:** ~35-42h (6-7 tygodni realistycznie)

---

### v3.3 (Q2 2026) - Automatyzacja i Kontrola
**Cel:** Kontrola Rodzicielska + Pełna Automatyzacja

**Funkcje:**
1. **Kontrola Rodzicielska** (Issue #26)
   - Profile Kids/Teens
   - Harmonogramy czasowe
   - Blokowanie kategorii
   - **Nakład pracy:** ~12-15h

2. **Pełne Auto-aktualizacje** (Issue #27)
   - Auto-aktualizacja wszystkich komponentów
   - Backup przed aktualizacją
   - Auto-rollback przy niepowodzeniu
   - **Nakład pracy:** ~10-12h

3. **Pełne Backup/Restore** (Issue #28)
   - Jedno-polecenie pełne backup systemu
   - Opcja backupu chmurowego (rsync/Nextcloud)
   - **Nakład pracy:** ~8-10h

**Razem:** ~30-37h (5-6 tygodni)

---

### v3.4 (Q3 2026) - Zunifikowana Architektura (Refaktoryzacja)
**Cel:** Konsolidacja modułów bez łamania zmian

**Podejście:** Stopniowa migracja, nie big-bang rewrite

**Faza 1: Fundamenty**
- Utwórz `lib/unified-helpers.sh` ze wspólnymi funkcjami
- Wyciągnij wspólne wzorce z istniejących modułów
- Brak łamania zmian
- **Nakład pracy:** ~8-10h

**Faza 2: Konsolidacja Modułów (per-wydanie)**
- v3.4.0: Scal `adblock.sh` + `blocklist-manager.sh` → `adblock-unified.sh`
- v3.4.1: Scal `config-backup.sh` + `lkg.sh` + `auto-update.sh` → `backup-unified.sh`
- v3.4.2: Scal `diagnostics.sh` + `discover.sh` + `health.sh` → `monitor-unified.sh`
- Każde: ~6-8h + testowanie

**Faza 3: Czyszczenie**
- Wycofaj stare moduły (zachowaj przez 2 wydania)
- Zaktualizuj dokumentację
- **Nakład pracy:** ~5h

**Razem:** ~25-35h przez 3 minor wydania

---

### v3.5+ (2027+) - Zaawansowane Funkcje
**Cel:** Zaawansowane funkcje (niski priorytet)

- Grafana/Prometheus (#19)
- IDS DNS (#20)
- Polityki per-urządzenie (#21)
- Sinkhole DNS (#22)
- Immutable OS (#23)
- Geo/ASN Firewall (#24)

**Tylko jeśli** istnieje popyt społeczności.

---

## Decyzje Techniczne

### 1. Brak Łamania Zmian w v3.2-v3.3
- Zachowaj istniejącą strukturę 29-modułową
- Dodaj nowe moduły obok istniejących
- Stare polecenia nadal działają

### 2. Refaktoryzacja w v3.4 (Stopniowa)
- Twórz zunifikowane moduły jako **nowe pliki**
- Stare moduły wywołują nowe (warstwa kompatybilności)
- Po 2 wydaniach usuń stare moduły

### 3. Struktura Poleceń

**v3.2-v3.3 (Aktualny styl):**
```bash
cytadela++ gateway-wizard
cytadela++ parental-add --profile=kids
```

**v3.4+ (Opcjonalny nowy styl):**
```bash
cytadela++ gateway wizard      # nowy zunifikowany
cytadela++ parental add --profile=kids  # nowy zunifikowany
# LUB zachowaj stary styl poprzez warstwę kompatybilności
```

---

## Łagodzenie Ryzyka

| Ryzyko | Łagodzenie |
|--------|------------|
| Gateway zbyt skomplikowany | Zacznij od podstawowego DHCP+NAT, dodawaj funkcje iteracyjnie |
| TUI dodaje zależności | Zrób opcjonalne, fallback do CLI jeśli brakuje ncurses |
| Refaktoryzacja v3.4 psuje rzeczy | Zachowaj stare moduły przez 2 wydania, testowanie równoległe |
| Przesunięcie harmonogramu | Obetnij zakres, nie jakość. Gateway MVP bez statystyk per-urządzenie ok |

---

## Kryteria Sukcesu

**v3.2:**
- [ ] Tryb gateway działa na maszynie 2-ethernetowej
- [ ] TUI działa bez GUI
- [ ] Wszystkie polecenia v3.1 nadal działają

**v3.3:**
- [ ] Kontrola rodzicielska blokuje strony dla dorosłych
- [ ] Auto-aktualizacja działa 7 dni bez problemów
- [ ] Backup/restore migruje na nową maszynę

**v3.4:**
- [ ] Liczba modułów zmniejszona (29 → ~15)
- [ ] Brak regresji funkcjonalnych
- [ ] Testy przechodzą dla wszystkich zunifikowanych modułów

---

## Następne Kroki

1. **Przejrzyj ten plan** - Potwierdź kierunek
2. **Utwórz issue śledzenia v3.2** - Gateway Mode
3. **Rozpocznij Gateway Mode** - Fundamenty DHCP + NAT
4. **Cotygodniowe check-iny** - Dostosowanie zakresu jeśli potrzebne

---

**Decyzja potrzebna:** Potwierdź Podejście Hybrydowe lub wybierz Alternatywę:
- **Alt A:** Pełna refaktoryzacja najpierw (v3.2 = 6 zunifikowanych modułów, przesuń funkcje do v3.4)
- **Alt B:** Pomiń refaktoryzację całkowicie (zachowaj 29 modułów, dodaj tylko funkcje)
