# 🔐 Plan Refaktoryzacji v3.3 - Zaawansowane Funkcje Bezpieczeństwa

**Wersja:** 3.3.0 PLANOWANA
**Utworzono:** 2026-01-31
**Status:** Faza planowania
**Szacowany czas:** 2-3 tygodnie (z pomocą AI)
**Wymagania wstępne:** v3.2.0 (Zunifikowana architektura modułów)

---

## 📋 Spis Treści

1. [Podsumowanie wykonawcze](#podsumowanie-wykonawcze)
2. [Przegląd nowych funkcji](#przegląd-nowych-funkcji)
3. [System reputacji](#system-reputacji)
4. [Blokowanie ASN](#blokowanie-asn)
5. [Logowanie zdarzeń](#logowanie-zdarzeń)
6. [Plan implementacji](#plan-implementacji)
7. [Harmonogram i kamienie milowe](#harmonogram-i-kamienie-milowe)
8. [Strategia testowania](#strategia-testowania)

---

## 🎯 Podsumowanie Wykonawcze

### Cele

- **Dodać System Reputacji:** Śledzenie i ocenianie adresów IP na podstawie zachowania
- **Dodać Blokowanie ASN:** Blokowanie całych Autonomicznych Systemów (sieci)
- **Dodać Logowanie Zdarzeń:** Strukturalne logi w formacie JSON do analizy i audytu
- **Dodać Honeypot:** Fałszywe usługi do wykrywania i auto-blokowania skanerów
- **Poprawić Bezpieczeństwo:** Proaktywne wykrywanie i blokowanie zagrożeń
- **Zachować Prostotę:** Zachować implementację Bash, bez over-engineering

### Korzyści

- ✅ Automatyczne wykrywanie zagrożeń
- ✅ Zmniejszone fałszywe pozytywy (vs proste czarne listy)
- ✅ Skalowalne blokowanie (ASN = setki IP)
- ✅ Lepszy audyt (strukturalne logi)
- ✅ Adaptacyjne bezpieczeństwo (uczy się z zachowania)

### Cele nieobejmowane

- ❌ Uczenie maszynowe / AI (zbyt skomplikowane)
- ❌ Reputacja oparta na grafach (zachować dla Aurora Mystica)
- ❌ Inspekcja pakietów w czasie rzeczywistym (poziom jądra)
- ❌ Rewrite w Rust (pozostać w Bash)

---

## 🆕 Przegląd Nowych Funkcji

### 1. System Reputacji

**Co to jest:** Prosty system oceniania dla adresów IP
**Dlaczego:** Lepiej niż czarne listy, adaptuje się do zachowania
**Jak:** Bash + SQLite/tekstowa baza danych

**Przykład:**
```bash
# IP zaczyna z oceną 1.0 (zaufany)
# Nieudane logowanie SSH: -0.1
# Wykrycie skanowania portów: -0.2
# Udane połączenie: +0.05
# Ocena < 0.15 → Auto-blokada
```

---

### 2. Blokowanie ASN

**Co to jest:** Blokowanie całych Autonomicznych Systemów (sieci)
**Dlaczego:** Jedna reguła blokuje setki IP
**Jak:** Bash + whois + nftables

**Przykład:**
```bash
# Zablokuj znane ASN botnetu
citadel asn-block AS12345

# Rezultat: ~500 prefiksów IP zablokowanych
# O wiele bardziej efektywne niż blokowanie indywidualnych IP
```

---

### 3. Logowanie Zdarzeń (JSON)

**Co to jest:** Strukturalne logi w formacie JSON
**Dlaczego:** Łatwe parsowanie, integracja z narzędziami
**Jak:** Bash + jq

**Przykład:**
```json
{
  "timestamp": "2026-01-31T20:00:00Z",
  "event_type": "silent_drop",
  "ip": "1.2.3.4",
  "score": 0.12,
  "reason": "low_reputation"
}
```

---

### 4. Honeypot

**Co to jest:** Fałszywe usługi do wykrywania skanerów
**Dlaczego:** Zero fałszywych pozytywów, auto-wykrywanie
**Jak:** Bash + netcat + systemd

**Przykład:**
```bash
# Fałszywy SSH na porcie 2222
# Każdy łączący się = skaner → auto-blokada
citadel honeypot install --port=2222 --service=ssh
```

---

## 📊 System Reputacji

### Architektura

```
Zdarzenie → Aktualizacja Oceny → Sprawdzenie Progu → Akcja
         (w bazie danych)        (< 0.15?)        (DROP/DOZWÓL)
```

### Schemat Bazy Danych

**Plik:** `/var/lib/cytadela/reputation.db`

**Format:** Czysty tekst (prosty, bez zależności SQLite)
```
# IP:OCENA:OSTATNIA_AKTUALIZACJA:ZDARZENIA
1.2.3.4:0.85:2026-01-31T20:00:00Z:3
5.6.7.8:0.12:2026-01-31T19:55:00Z:15
```

### Implementacja

**Plik:** `lib/reputation.sh`

```bash
#!/bin/bash

REPUTATION_DB="/var/lib/cytadela/reputation.db"
REPUTATION_THRESHOLD="0.15"

# Inicjalizacja bazy danych
reputation_init() {
    mkdir -p "$(dirname "$REPUTATION_DB")"
    touch "$REPUTATION_DB"
}

# Pobierz ocenę dla IP
reputation_get_score() {
    local ip="$1"
    
    if [[ -f "$REPUTATION_DB" ]]; then
        local line
        line=$(grep "^$ip:" "$REPUTATION_DB" 2>/dev/null)
        
        if [[ -n "$line" ]]; then
            echo "$line" | cut -d: -f2
        else
            echo "1.0"  # Domyślnie: zaufany
        fi
    else
        echo "1.0"
    fi
}

# Aktualizuj ocenę dla IP
reputation_update_score() {
    local ip="$1"
    local delta="$2"
    
    local current_score
    current_score=$(reputation_get_score "$ip")
    
    local new_score
    new_score=$(echo "$current_score + $delta" | bc -l)
    
    # Przytnij do 0.0-1.0
    if (( $(echo "$new_score < 0.0" | bc -l) )); then
        new_score="0.0"
    elif (( $(echo "$new_score > 1.0" | bc -l) )); then
        new_score="1.0"
    fi
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Aktualizuj lub wstaw
    if grep -q "^$ip:" "$REPUTATION_DB" 2>/dev/null; then
        # Aktualizuj istniejący
        local events
        events=$(grep "^$ip:" "$REPUTATION_DB" | cut -d: -f4)
        events=$((events + 1))
        
        sed -i "s|^$ip:.*|$ip:$new_score:$timestamp:$events|" "$REPUTATION_DB"
    else
        # Wstaw nowy
        echo "$ip:$new_score:$timestamp:1" >> "$REPUTATION_DB"
    fi
    
    # Sprawdź próg
    if (( $(echo "$new_score < $REPUTATION_THRESHOLD" | bc -l) )); then
        firewall_silent_drop "$ip"
        log_event "auto_block" "$ip" "$new_score" "reputation_threshold"
    fi
    
    log_info "Reputacja zaktualizowana: $ip ocena=$new_score (delta=$delta)"
}

# Śledź zdarzenie i aktualizuj reputację
reputation_track_event() {
    local ip="$1"
    local event_type="$2"
    
    local delta
    case "$event_type" in
        "failed_ssh_login")
            delta="-0.10"
            ;;
        "port_scan")
            delta="-0.20"
            ;;
        "failed_dns_query")
            delta="-0.05"
            ;;
        "successful_connection")
            delta="+0.05"
            ;;
        "manual_trust")
            delta="+0.50"
            ;;
        *)
            delta="0.0"
            ;;
    esac
    
    reputation_update_score "$ip" "$delta"
}

# Wyświetl wszystkie IP z niską reputacją
reputation_list_suspicious() {
    local threshold="${1:-$REPUTATION_THRESHOLD}"
    
    if [[ ! -f "$REPUTATION_DB" ]]; then
        echo "Nie znaleziono bazy danych reputacji"
        return
    fi
    
    echo "IP z oceną < $threshold:"
    echo "IP              Ocena   Zdarzenia  Ostatnia Aktualizacja"
    echo "------------------------------------------------"
    
    while IFS=: read -r ip score timestamp events; do
        if (( $(echo "$score < $threshold" | bc -l) )); then
            printf "%-15s %-7s %-7s %s\n" "$ip" "$score" "$events" "$timestamp"
        fi
    done < "$REPUTATION_DB"
}

# Resetuj reputację dla IP
reputation_reset() {
    local ip="$1"
    
    sed -i "/^$ip:/d" "$REPUTATION_DB"
    log_info "Reputacja zresetowana dla $ip"
}

# Wyczyść stare wpisy (starsze niż 30 dni)
reputation_cleanup() {
    local days="${1:-30}"
    local cutoff_date
    cutoff_date=$(date -u -d "$days days ago" +"%Y-%m-%dT%H:%M:%SZ")
    
    local temp_file
    temp_file=$(mktemp)
    
    while IFS=: read -r ip score timestamp events; do
        if [[ "$timestamp" > "$cutoff_date" ]]; then
            echo "$ip:$score:$timestamp:$events" >> "$temp_file"
        fi
    done < "$REPUTATION_DB"
    
    mv "$temp_file" "$REPUTATION_DB"
    log_info "Wyczyszczono bazę danych reputacji (starsze niż $days dni)"
}
```

### Polecenia

```bash
# Ręczne polecenia
citadel reputation list [--threshold=0.15]
citadel reputation reset <ip>
citadel reputation cleanup [--days=30]
citadel reputation track <ip> <event>
```

---

## 🌍 Blokowanie ASN

### Architektura

```
ASN → Wyszukaj Prefiksy → Dodaj do nftables → Log
      (whois)            (zakresy IP)
```

### Implementacja

**Plik:** `lib/asn-blocking.sh`

```bash
#!/bin/bash

ASN_BLOCKLIST="/etc/cytadela/asn-blocklist.txt"
ASN_CACHE="/var/lib/cytadela/asn-cache/"

# Inicjalizuj blokowanie ASN
asn_init() {
    mkdir -p "$(dirname "$ASN_BLOCKLIST")"
    mkdir -p "$ASN_CACHE"
    
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        cat > "$ASN_BLOCKLIST" <<EOF
# Lista blokowania ASN Cytadela
# Format: AS<numer> [# komentarz]
# Przykład:
# AS12345  # Znany botnet
# AS67890  # Bulletproof hosting

# Dodaj swoje ASN poniżej:

EOF
    fi
}

# Pobierz prefiksy IP dla ASN
asn_get_prefixes() {
    local asn="$1"
    local cache_file="$ASN_CACHE/${asn}.txt"
    
    # Sprawdź cache (ważny przez 24h)
    if [[ -f "$cache_file" ]]; then
        local cache_age
        cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        
        if (( cache_age < 86400 )); then
            cat "$cache_file"
            return
        fi
    fi
    
    # Pobierz z whois
    local prefixes
    prefixes=$(whois -h whois.radb.net -- "-i origin $asn" 2>/dev/null | \
               grep "^route:" | \
               awk '{print $2}' | \
               sort -u)
    
    if [[ -n "$prefixes" ]]; then
        echo "$prefixes" > "$cache_file"
        echo "$prefixes"
    else
        log_error "Nie udało się pobrać prefiksów dla $asn"
        return 1
    fi
}

# Zablokuj ASN
asn_block() {
    local asn="$1"
    
    log_info "Blokowanie ASN $asn..."
    
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")
    
    if [[ -z "$prefixes" ]]; then
        log_error "Nie znaleziono prefiksów dla $asn"
        return 1
    fi
    
    local count=0
    while IFS= read -r prefix; do
        [[ -z "$prefix" ]] && continue
        
        # Dodaj do nftables
        nft add rule inet filter input ip saddr "$prefix" drop 2>/dev/null
        
        ((count++))
    done <<< "$prefixes"
    
    log_info "Zablokowano $count prefiksów dla $asn"
    log_event "asn_block" "$asn" "$count" "manual"
}

# Odblokuj ASN
asn_unblock() {
    local asn="$1"
    
    log_info "Odblokowywanie ASN $asn..."
    
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")
    
    if [[ -z "$prefixes" ]]; then
        log_error "Nie znaleziono prefiksów dla $asn"
        return 1
    fi
    
    local count=0
    while IFS= read -r prefix; do
        [[ -z "$prefix" ]] && continue
        
        # Usuń z nftables (znajdź handle i usuń)
        local handle
        handle=$(nft -a list ruleset | grep "$prefix" | grep -oP 'handle \K\d+')
        
        if [[ -n "$handle" ]]; then
            nft delete rule inet filter input handle "$handle" 2>/dev/null
            ((count++))
        fi
    done <<< "$prefixes"
    
    log_info "Odblokowano $count prefiksów dla $asn"
}

# Zablokuj wszystkie ASN z listy blokowania
asn_block_from_list() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        log_error "Lista blokowania ASN nie znaleziona: $ASN_BLOCKLIST"
        return 1
    fi
    
    local total=0
    while IFS= read -r line; do
        # Pomiń komentarze i puste linie
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        # Wyciągnij ASN (pierwsze słowo)
        local asn
        asn=$(echo "$line" | awk '{print $1}')
        
        asn_block "$asn"
        ((total++))
    done < "$ASN_BLOCKLIST"
    
    log_info "Zablokowano $total ASN z listy blokowania"
}

# Wyświetl zablokowane ASN
asn_list() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        echo "Nie znaleziono listy blokowania ASN"
        return
    fi
    
    echo "Zablokowane ASN:"
    echo "ASN       Prefiksy  Komentarz"
    echo "----------------------------------------"
    
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        local asn comment
        asn=$(echo "$line" | awk '{print $1}')
        comment=$(echo "$line" | cut -d'#' -f2- 2>/dev/null)
        
        local prefix_count=0
        if [[ -f "$ASN_CACHE/${asn}.txt" ]]; then
            prefix_count=$(wc -l < "$ASN_CACHE/${asn}.txt")
        fi
        
        printf "%-9s %-9s %s\n" "$asn" "$prefix_count" "$comment"
    done < "$ASN_BLOCKLIST"
}

# Dodaj ASN do listy blokowania
asn_add() {
    local asn="$1"
    local comment="${2:-}"
    
    if grep -q "^$asn" "$ASN_BLOCKLIST" 2>/dev/null; then
        log_warn "ASN $asn już na liście blokowania"
        return 1
    fi
    
    if [[ -n "$comment" ]]; then
        echo "$asn  # $comment" >> "$ASN_BLOCKLIST"
    else
        echo "$asn" >> "$ASN_BLOCKLIST"
    fi
    
    log_info "Dodano $asn do listy blokowania"
    
    # Zablokuj natychmiast
    asn_block "$asn"
}

# Usuń ASN z listy blokowania
asn_remove() {
    local asn="$1"
    
    if ! grep -q "^$asn" "$ASN_BLOCKLIST" 2>/dev/null; then
        log_warn "ASN $asn nie na liście blokowania"
        return 1
    fi
    
    # Odblokuj najpierw
    asn_unblock "$asn"
    
    # Usuń z listy blokowania
    sed -i "/^$asn/d" "$ASN_BLOCKLIST"
    
    log_info "Usunięto $asn z listy blokowania"
}
```

### Polecenia

```bash
# Ręczne polecenia
citadel asn-block <AS12345>
citadel asn-unblock <AS12345>
citadel asn-list
citadel asn-add <AS12345> [komentarz]
citadel asn-remove <AS12345>
citadel asn-update  # Ponownie pobierz wszystkie prefiksy
```

---

## 📝 Logowanie Zdarzeń

### Architektura

```
Zdarzenie → Formatuj JSON → Dołącz do Logu → Obróć
                      (/var/log/cytadela/events.json)
```

### Implementacja

**Plik:** `lib/event-logger.sh`

```bash
#!/bin/bash

EVENT_LOG="/var/log/cytadela/events.json"
EVENT_LOG_MAX_SIZE="10M"  # Obróć po 10MB

# Inicjalizuj logowanie zdarzeń
event_log_init() {
    mkdir -p "$(dirname "$EVENT_LOG")"
    touch "$EVENT_LOG"
}

# Zaloguj zdarzenie w formacie JSON
log_event() {
    local event_type="$1"
    local target="$2"
    local value="$3"
    local reason="$4"
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Utwórz zdarzenie JSON
    local event_json
    event_json=$(cat <<EOF
{"timestamp":"$timestamp","event_type":"$event_type","target":"$target","value":"$value","reason":"$reason"}
EOF
)
    
    # Dołącz do logu
    echo "$event_json" >> "$EVENT_LOG"
    
    # Sprawdź czy obrót potrzebny
    event_log_rotate_if_needed
}

# Obróć log jeśli zbyt duży
event_log_rotate_if_needed() {
    if [[ ! -f "$EVENT_LOG" ]]; then
        return
    fi
    
    local size
    size=$(stat -c %s "$EVENT_LOG" 2>/dev/null || echo 0)
    local max_size
    max_size=$(numfmt --from=iec "$EVENT_LOG_MAX_SIZE")
    
    if (( size > max_size )); then
        event_log_rotate
    fi
}

# Obróć plik logu
event_log_rotate() {
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    
    mv "$EVENT_LOG" "${EVENT_LOG}.${timestamp}"
    gzip "${EVENT_LOG}.${timestamp}"
    
    touch "$EVENT_LOG"
    
    log_info "Obrócono log zdarzeń: ${EVENT_LOG}.${timestamp}.gz"
    
    # Zachowaj tylko ostatnie 10 obróconych logów
    ls -t "${EVENT_LOG}".*.gz 2>/dev/null | tail -n +11 | xargs rm -f
}

# Przeszukaj zdarzenia
event_query() {
    local event_type="${1:-}"
    local hours="${2:-24}"
    
    if [[ ! -f "$EVENT_LOG" ]]; then
        echo "Brak zalogowanych zdarzeń"
        return
    fi
    
    local cutoff
    cutoff=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")
    
    if command -v jq &>/dev/null; then
        # Użyj jq dla ładnego wyjścia
        if [[ -n "$event_type" ]]; then
            jq -r "select(.timestamp > \"$cutoff\" and .event_type == \"$event_type\")" "$EVENT_LOG"
        else
            jq -r "select(.timestamp > \"$cutoff\")" "$EVENT_LOG"
        fi
    else
        # Fallback: grep
        if [[ -n "$event_type" ]]; then
            grep "\"event_type\":\"$event_type\"" "$EVENT_LOG" | \
            awk -v cutoff="$cutoff" -F'"timestamp":"' '$2 > cutoff'
        else
            awk -v cutoff="$cutoff" -F'"timestamp":"' '$2 > cutoff' "$EVENT_LOG"
        fi
    fi
}

# Statystyki zdarzeń
event_stats() {
    local hours="${1:-24}"
    
    if [[ ! -f "$EVENT_LOG" ]]; then
        echo "Brak zalogowanych zdarzeń"
        return
    fi
    
    local cutoff
    cutoff=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "Statystyki zdarzeń (ostatnie $hours godzin):"
    echo "Typ Zdarzenia       Liczba"
    echo "-----------------------------"
    
    if command -v jq &>/dev/null; then
        jq -r "select(.timestamp > \"$cutoff\") | .event_type" "$EVENT_LOG" | \
        sort | uniq -c | sort -rn | \
        awk '{printf "%-20s %s\n", $2, $1}'
    else
        awk -v cutoff="$cutoff" -F'"' '
            $4 > cutoff {
                for(i=1; i<=NF; i++) {
                    if($i == "event_type") {
                        print $(i+2)
                    }
                }
            }
        ' "$EVENT_LOG" | sort | uniq -c | sort -rn | \
        awk '{printf "%-20s %s\n", $2, $1}'
    fi
}
```

### Polecenia

```bash
# Przeszukaj zdarzenia
citadel events query [event_type] [--hours=24]
citadel events stats [--hours=24]
citadel events rotate
```

---

## 📅 Plan Implementacji

### Faza 1: Biblioteki rdzenia (Tydzień 1)

**Zadania:**
1. Utwórz `lib/reputation.sh`
2. Utwórz `lib/asn-blocking.sh`
3. Utwórz `lib/event-logger.sh`
4. Utwórz `lib/honeypot.sh`
5. Dodaj do `lib/module-loader.sh`

**Rezultaty:**
- 4 nowe pliki biblioteczne
- Testy jednostkowe dla każdego

**Czas:** 4-5 dni

---

### Faza 2: Integracja (Tydzień 1-2)

**Zadania:**
1. Zintegruj śledzenie reputacji z `unified-security.sh`
2. Zintegruj blokowanie ASN z `unified-security.sh`
3. Zintegruj honeypot z `unified-security.sh`
4. Zintegruj logowanie zdarzeń z wszystkimi modułami
5. Dodaj nowe polecenia do głównych skryptów

**Rezultaty:**
- Zaktualizowany `unified-security.sh`
- Dostępne nowe polecenia

**Czas:** 4-5 dni

---

### Faza 3: Automatyzacja (Tydzień 2)

**Zadania:**
1. Utwórz timer systemd dla czyszczenia reputacji
2. Utwórz timer systemd dla aktualizacji ASN
3. Utwórz usługę systemd dla honeypot
4. Dodaj hooki dla automatycznego śledzenia reputacji
5. Skonfiguruj rotację logów

**Rezultaty:**
- Timery systemd
- Usługa honeypot
- Hooki automatycznego śledzenia

**Czas:** 3-4 dni

---

### Faza 4: Testowanie i dokumentacja (Tydzień 2-3)

**Zadania:**
1. Testy jednostkowe dla wszystkich nowych funkcji
2. Testy integracyjne
3. Aktualizacja MANUAL_PL.md
4. Aktualizacja MANUAL_EN.md
5. Aktualizacja commands.md
6. Utworzenie przewodnika migracji

**Rezultaty:**
- Kompletny zestaw testów
- Zaktualizowana dokumentacja

**Czas:** 3-5 dni

---

## ⏰ Harmonogram i Kamienie Milowe

### Tydzień 1: Implementacja Rdzenia

- **Dzień 1-2:** System reputacji
- **Dzień 3-4:** Blokowanie ASN
- **Dzień 5:** Logowanie zdarzeń + Honeypot
- **Kamień milowy:** Wszystkie biblioteki kompletne

### Tydzień 2: Integracja i Automatyzacja

- **Dzień 1-2:** Integracja z zunifikowanymi modułami
- **Dzień 3-4:** Automatyzacja (timery systemd)
- **Dzień 5:** Testowanie
- **Kamień milowy:** Wszystkie funkcje działające

### Tydzień 3: Dokumentacja i Wydanie

- **Dzień 1-3:** Aktualizacje dokumentacji
- **Dzień 4-5:** Ostateczne testowanie, poprawki błędów
- **Kamień milowy:** v3.3.0 gotowa do wydania

---

## 🧪 Strategia Testowania

### Testy Jednostkowe

```bash
# Test systemu reputacji
test_reputation_get_score
test_reputation_update_score
test_reputation_track_event
test_reputation_cleanup

# Test blokowania ASN
test_asn_get_prefixes
test_asn_block
test_asn_unblock

# Test logowania zdarzeń
test_log_event
test_event_query
test_event_rotate
```

### Testy Integracyjne

```bash
# Test pełnego przepływu
test_failed_ssh_triggers_reputation_update
test_low_reputation_triggers_auto_block
test_asn_block_blocks_all_prefixes
test_events_logged_correctly
```

### Testy Ręczne

- Wyzwól nieudane logowanie SSH, zweryfikuj aktualizację reputacji
- Dodaj ASN do listy blokowania, zweryfikuj zablokowane prefiksy
- Przeszukaj zdarzenia, zweryfikuj format JSON
- Sprawdź rotację logów

---

## 📊 Kryteria Sukcesu

### Techniczne

- ✅ System reputacji śledzi IP prawidłowo
- ✅ Blokowanie ASN blokuje wszystkie prefiksy
- ✅ Logowanie zdarzeń produkuje prawidłowy JSON
- ✅ Wszystkie testy przechodzą
- ✅ Brak degradacji wydajności

### Doświadczenie Użytkownika

- ✅ Proste polecenia
- ✅ Jasna dokumentacja
- ✅ Automatyczna operacja (minimalna ręczna interwencja)
- ✅ Łatwe rozwiązywanie problemów

---

## 🚀 Strategia Wdrożenia

### Wydanie Alpha (Wewnętrzne)

- **Wersja:** v3.3.0-alpha
- **Czas trwania:** 1 tydzień
- **Cel:** Znajdź krytyczne błędy

### Wydanie Beta (Wcześni Adopci)

- **Wersja:** v3.3.0-beta
- **Czas trwania:** 2 tygodnie
- **Cel:** Testowanie w rzeczywistym świecie

### Wydanie Stabilne

- **Wersja:** v3.3.0
- **Ogłoszenie:** GitHub, społeczność

---

**Ostatnia aktualizacja:** 2026-01-31
**Wersja:** 1.0
**Status:** Faza planowania
**Następna recenzja:** Po wydaniu v3.2.0
