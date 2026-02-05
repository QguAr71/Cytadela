# Cytadela v3.2 - Procedura Testowania Środowiska

**Wersja:** 3.2.0
**Data:** 2026-02-04
**Cel:** Kompletna procedura testowania Cytadeli v3.2 w środowisku użytkownika
**Poziom Ryzyka:** Niski (włączone procedury wycofania)

---

## Spis Treści

1. [Wymagania wstępne](#wymagania-wstępne)
2. [Przygotowanie środowiska](#przygotowanie-środowiska)
3. [Bezpieczna konfiguracja testowa](#bezpieczna-konfiguracja-testowa)
4. [Testowanie modułów unifikowanych](#testowanie-modułów-unifikowanych)
5. [Testowanie kompatybilności wstecznej](#testowanie-kompatybilności-wstecznej)
6. [Testowanie funkcji krytycznych](#testowanie-funkcji-krytycznych)
7. [Testowanie wydajności](#testowanie-wydajności)
8. [Testowanie integracji](#testowanie-integracji)
9. [Weryfikacja dokumentacji](#weryfikacja-dokumentacji)
10. [Procedury czyszczenia](#procedury-czyszczenia)
11. [Rozwiązywanie problemów](#rozwiązywanie-problemów)
12. [Kryteria sukcesu](#kryteria-sukcesu)

---

## Wymagania wstępne

### Wymagania systemowe
```bash
# Wymagane pakiety (zainstaluj jeśli brakuje)
pacman -S bash coreutils grep awk sed curl jq  # Arch Linux
apt install bash coreutils grep awk sed curl jq  # Ubuntu/Debian
dnf install bash coreutils grep awk sed curl jq  # Fedora/RHEL

# Opcjonalne ale zalecane dla pełnego testowania
pacman -S dnsperf htop iotop  # Arch Linux
apt install dnsperf htop iotop  # Ubuntu/Debian
dnf install dnsperf htop iotop  # Fedora/RHEL
```

### Kopia zapasowa aktualnego systemu
```bash
# Utwórz kopię zapasową systemu przed testowaniem
sudo mkdir -p /var/lib/cytadela/backups
sudo cp /etc/resolv.conf /var/lib/cytadela/backups/resolv.conf.backup
sudo cp -r /etc/coredns /var/lib/cytadela/backups/coredns.backup 2>/dev/null || true
sudo cp -r /etc/dnscrypt-proxy /var/lib/cytadela/backups/dnscrypt.backup 2>/dev/null || true

echo "Kopia zapasowa utworzona w /var/lib/cytadela/backups/"
```

### Izolacja środowiska testowego
```bash
# Utwórz izolowany katalog testowy
mkdir -p ~/cytadela-test
cd ~/cytadela-test

# Sklonuj świeżą kopię do testowania
git clone https://github.com/your-org/cytadela.git .
git checkout develop  # lub gałąź v3.2

# Zrób skrypty wykonywalne
chmod +x citadel.sh
find modules/unified -name "*.sh" -exec chmod +x {} \;
```

---

## Przygotowanie środowiska

### 1. Zbieranie informacji o systemie
```bash
# Zbierz informacje o systemie
echo "=== INFORMACJE O SYSTEMIE ==="
uname -a
echo "Wersja Bash: $BASH_VERSION"
echo "Użytkownik: $(whoami)"
echo "Katalog roboczy: $(pwd)"
echo "Dostępna pamięć: $(free -h | grep Mem | awk '{print $2}')"
echo "Dostępny dysk: $(df -h . | tail -1 | awk '{print $4}')"
```

### 2. Test łączności sieciowej
```bash
# Test podstawowej łączności sieciowej
echo "=== ŁĄCZNOŚĆ SIECIOWA ==="
ping -c 3 8.8.8.8
ping -c 3 google.com
curl -s https://1.1.1.1/cdn-cgi/trace | head -5
```

### 3. Test rozwiązywania DNS
```bash
# Test aktualnego rozwiązywania DNS
echo "=== AKTUALNE ROZWIĄZYWANIE DNS ==="
echo "Serwery DNS w /etc/resolv.conf:"
grep nameserver /etc/resolv.conf

echo "Test rozwiązywania DNS:"
dig +short google.com @127.0.0.1 2>/dev/null || echo "Lokalny DNS nie odpowiada (oczekiwane)"

# Kopia zapasowa aktualnego resolv.conf
sudo cp /etc/resolv.conf /etc/resolv.conf.backup-test
```

### 4. Sprawdzenie statusu usług
```bash
# Sprawdź czy usługi DNS działają
echo "=== AKTUALNY STATUS USŁUG ==="
systemctl is-active --quiet systemd-resolved && echo "systemd-resolved: AKTYWNY" || echo "systemd-resolved: NIEAKTYWNY"
systemctl is-active --quiet dnscrypt-proxy && echo "dnscrypt-proxy: AKTYWNY" || echo "dnscrypt-proxy: NIEAKTYWNY"
systemctl is-active --quiet coredns && echo "coredns: AKTYWNY" || echo "coredns: NIEAKTYWNY"
```

---

## Bezpieczna konfiguracja testowa

### 1. Izolowana konfiguracja
```bash
# Utwórz konfigurację specyficzną dla testów
export CYTADELA_TEST_MODE=1
export CYTADELA_STATE_DIR="/tmp/cytadela-test-state"
mkdir -p "$CYTADELA_STATE_DIR"

# Użyj katalogów specyficznych dla testów
export COREDNS_CONFIG_DIR="/tmp/cytadela-test-coredns"
export DNSCRYPT_CONFIG_DIR="/tmp/cytadela-test-dnscrypt"
mkdir -p "$COREDNS_CONFIG_DIR" "$DNSCRYPT_CONFIG_DIR"

echo "Środowisko testowe izolowane:"
echo "Katalog stanu: $CYTADELA_STATE_DIR"
echo "Katalog CoreDNS: $COREDNS_CONFIG_DIR"
echo "Katalog DNSCrypt: $DNSCRYPT_CONFIG_DIR"
```

### 2. Konfiguracja testowego DNS
```bash
# Utwórz konfigurację testowego DNS (nie wpływa na system)
cat > "$COREDNS_CONFIG_DIR/Corefile.test" << 'EOF'
.:53 {
    bind 127.0.0.1
    forward . 8.8.8.8 1.1.1.1
    log
}
EOF

echo "Konfiguracja testowego DNS utworzona w $COREDNS_CONFIG_DIR/Corefile.test"
```

### 3. Przygotowanie skryptu testowego
```bash
# Utwórz skrypt uruchamiający testy
cat > test-environment.sh << 'EOF'
#!/bin/bash
# Cytadela - Uruchamiający Testy Środowiska

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# Funkcje testowe będą dodane tutaj
EOF

chmod +x test-environment.sh
echo "Skrypt uruchamiający testy utworzony: test-environment.sh"
```

---

## Testowanie modułów unifikowanych

### 1. Testy ładowania modułów
```bash
echo "=== TESTOWANIE ŁADOWANIA MODUŁÓW UNIFIKOWANYCH ==="

# Test każdy moduł unifikowany ładuje się bez błędów
modules=("recovery" "install" "security" "network" "adblock" "backup" "monitor")

for module in "${modules[@]}"; do
    echo "Testowanie modułu: $module"
    if ./citadel.sh "$module" status 2>&1 | grep -q "status\|Status\|STATUS"; then
        echo "✓ Moduł $module załadowany pomyślnie"
    else
        echo "✗ Moduł $module nie załadował się"
        ./citadel.sh "$module" status 2>&1 | head -5
    fi
    echo ""
done
```

### 2. Testy składni modułów
```bash
echo "=== TESTOWANIE SKŁADNI MODUŁÓW ==="

for module_file in modules/unified/*.sh; do
    echo "Testowanie składni: $(basename "$module_file")"
    if bash -n "$module_file" 2>&1; then
        echo "✓ Składnia OK"
    else
        echo "✗ Znalezione błędy składni:"
        bash -n "$module_file"
    fi
    echo ""
done
```

### 3. Testy dostępności funkcji
```bash
echo "=== TESTOWANIE DOSTĘPNOŚCI FUNKCJI ==="

# Test krytyczne funkcje istnieją
test_functions=(
    "recovery panic-status"
    "install check-deps"
    "security integrity-status"
    "network ipv6-privacy-status"
    "adblock status"
    "backup config-list"
    "monitor diagnostics"
)

for func in "${test_functions[@]}"; do
    echo "Testowanie funkcji: $func"
    if ./citadel.sh $func 2>&1 | grep -q "status\|Status\|available\|Available"; then
        echo "✓ Funkcja $func dostępna"
    else
        echo "✗ Funkcja $func niedostępna lub nie działa"
        ./citadel.sh $func 2>&1 | head -3
    fi
    echo ""
done
```

---

## Testowanie kompatybilności wstecznej

### 1. Testy poleceń legacy
```bash
echo "=== TESTOWANIE KOMPATYBILNOŚCI WSTECZNEJ ==="

# Test stare polecenia nadal działają
legacy_commands=(
    "panic-status"
    "install-all"
    "adblock-status"
    "allowlist-list"
    "blocklist-list"
    "config-list"
    "lkg-status"
    "auto-update-status"
    "diagnostics"
    "verify-stack"
)

for cmd in "${legacy_commands[@]}"; do
    echo "Testowanie polecenia legacy: $cmd"
    if ./citadel.sh "$cmd" 2>&1 | grep -q "status\|Status\|available\|Available\|OK\|ok"; then
        echo "✓ Polecenie legacy '$cmd' działa"
    elif ./citadel.sh "$cmd" 2>&1 | grep -q "root\|sudo"; then
        echo "~ Polecenie legacy '$cmd' wymaga root (oczekiwane)"
    else
        echo "✗ Polecenie legacy '$cmd' nie działa"
        ./citadel.sh "$cmd" 2>&1 | head -3
    fi
    echo ""
done
```

### 2. Testy kompatybilności aliasów
```bash
echo "=== TESTOWANIE ALIASÓW POLECEŃ ==="

# Test że stare aliasy nadal działają
alias_tests=(
    "blocklist:blocklist-list"
    "combined:adblock show combined"
    "custom:adblock show custom"
)

for alias_test in "${alias_tests[@]}"; do
    IFS=':' read -r alias_cmd expected <<< "$alias_test"
    echo "Testowanie aliasu: $alias_cmd"

    output=$(./citadel.sh "$alias_cmd" 2>&1)
    if echo "$output" | grep -q "blocklist\|Blocklist\|entries\|Entries"; then
        echo "✓ Alias '$alias_cmd' działa"
    else
        echo "✗ Alias '$alias_cmd' nie działa"
        echo "$output" | head -3
    fi
    echo ""
done
```

---

## Testowanie funkcji krytycznych

### 1. Testy funkcjonalności DNS
```bash
echo "=== TESTOWANIE FUNKCJONALNOŚCI DNS ==="

# Test rozwiązywania DNS z różnymi resolverami
resolvers=("8.8.8.8" "1.1.1.1" "208.67.222.222")

for resolver in "${resolvers[@]}"; do
    echo "Testowanie resolvera DNS: $resolver"
    if dig +short +time=3 @${resolver} google.com | grep -q "[0-9]"; then
        echo "✓ Resolver DNS $resolver działa"
    else
        echo "✗ Resolver DNS $resolver nie działa"
    fi
done

# Test lokalnego DNS (jeśli skonfigurowany)
echo "Testowanie rozwiązywania lokalnego DNS:"
if dig +short +time=3 @127.0.0.1 google.com 2>/dev/null | grep -q "[0-9]"; then
    echo "✓ Lokalny DNS (127.0.0.1) działa"
else
    echo "~ Lokalny DNS nie skonfigurowany lub nie działa (oczekiwane w środowisku testowym)"
fi
```

### 2. Testy walidacji konfiguracji
```bash
echo "=== TESTOWANIE WALIDACJI KONFIGURACJI ==="

# Test walidacji plików konfiguracyjnych
config_tests=(
    "lib/unified-core.sh:bash -n"
    "lib/module-loader.sh:bash -n"
    "citadel.sh:bash -n"
)

for config_test in "${config_tests[@]}"; do
    IFS=':' read -r file validator <<< "$config_test"
    echo "Testowanie konfiguracji: $file"

    if [[ -f "$file" ]] && $validator "$file" 2>/dev/null; then
        echo "✓ Plik konfiguracyjny $file prawidłowy"
    else
        echo "✗ Plik konfiguracyjny $file nieprawidłowy lub brakujący"
    fi
done
```

### 3. Sprawdzania bezpieczeństwa
```bash
echo "=== TESTOWANIE FUNKCJI BEZPIECZEŃSTWA ==="

# Test uprawnień plików
security_tests=(
    "citadel.sh:executable"
    "modules/unified/:readable"
    "lib/:readable"
)

for security_test in "${security_tests[@]}"; do
    IFS=':' read -r path check <<< "$security_test"
    echo "Testowanie bezpieczeństwa: $path ($check)"

    case $check in
        executable)
            if [[ -x "$path" ]]; then
                echo "✓ Plik $path jest wykonywalny"
            else
                echo "✗ Plik $path nie jest wykonywalny"
            fi
            ;;
        readable)
            if [[ -r "$path" ]]; then
                echo "✓ Ścieżka $path jest czytelna"
            else
                echo "✗ Ścieżka $path nie jest czytelna"
            fi
            ;;
    esac
done
```

---

## Testowanie wydajności

### 1. Testy czasu ładowania modułów
```bash
echo "=== TESTOWANIE CZASÓW ŁADOWANIA MODUŁÓW ==="

for module in "${modules[@]}"; do
    echo "Testowanie czasu ładowania dla modułu: $module"
    start_time=$(date +%s%N)
    ./citadel.sh "$module" status >/dev/null 2>&1
    end_time=$(date +%s%N)
    load_time=$(( (end_time - start_time) / 1000000 ))

    if [[ $load_time -lt 2000 ]]; then
        echo "✓ Moduł $module załadowany w ${load_time}ms"
    else
        echo "⚠ Moduł $module wolne ładowanie: ${load_time}ms"
    fi
done
```

### 2. Testy użycia pamięci
```bash
echo "=== TESTOWANIE UŻYCIA PAMIĘCI ==="

# Pobierz początkową pamięć
initial_mem=$(ps -o rss= $$)

# Załaduj wszystkie moduły
for module in "${modules[@]}"; do
    ./citadel.sh "$module" status >/dev/null 2>&1
done

# Pobierz końcową pamięć
final_mem=$(ps -o rss= $$)
mem_increase=$((final_mem - initial_mem))

echo "Użycie pamięci:"
echo "  Początkowe: $initial_mem KB"
echo "  Końcowe: $final_mem KB"
echo "  Zwiększenie: $mem_increase KB"

if [[ $mem_increase -lt 50000 ]]; then
    echo "✓ Użycie pamięci akceptowalne"
else
    echo "⚠ Wykryte wysokie użycie pamięci"
fi
```

---

## Testowanie integracji

### 1. Testy przepływów end-to-end
```bash
echo "=== TESTOWANIE PRZEPŁYWÓW END-TO-END ==="

# Test kompletnych sekwencji przepływów
workflows=(
    "Przepływ poleceń unifikowanych:install check-deps → security integrity-init → network ipv6-privacy-status"
    "Przepływ kompatybilności legacy:adblock-status → allowlist-list → blocklist-list"
    "Przepływ mieszany:monitor diagnostics → backup config-list → recovery panic-status"
)

for workflow in "${workflows[@]}"; do
    echo "Testowanie przepływu: $workflow"
    echo "~ Wymagane testowanie ręczne dla pełnych przepływów"
    echo "~ Polecenia są dostępne i powinny działać w sekwencji"
    echo ""
done
```

### 2. Testy interakcji między modułami
```bash
echo "=== TESTOWANIE INTERAKCJI MIĘDZY MODUŁAMI ==="

# Test że moduły mogą współpracować
echo "Testowanie integracji adblock + backup:"
echo "~ adblock rebuild powinien działać z backup LKG"
echo "~ Wymagana weryfikacja ręczna"

echo ""
echo "Testowanie integracji security + network:"
echo "~ sprawdzania integralności powinny działać z konfiguracjami sieciowymi"
echo "~ Wymagana weryfikacja ręczna"
```

---

## Weryfikacja dokumentacji

### 1. Weryfikacja ręczna
```bash
echo "=== WERYFIKACJA DOKUMENTACJI ==="

docs=(
    "docs/MANUAL_EN.md"
    "docs/MANUAL_PL.md"
    "docs/UNIFIED-MODULES-DOCUMENTATION.md"
    "docs/REFACTORING-V3.2-ROADMAP.md"
)

for doc in "${docs[@]}"; do
    echo "Sprawdzanie dokumentacji: $doc"
    if [[ -f "$doc" ]] && [[ -s "$doc" ]]; then
        lines=$(wc -l < "$doc")
        echo "✓ Dokumentacja $doc istnieje ($lines linii)"
    else
        echo "✗ Dokumentacja $doc brakująca lub pusta"
    fi
done
```

### 2. Weryfikacja systemu pomocy
```bash
echo "=== TESTOWANIE SYSTEMU POMOCY ==="

# Test głównej pomocy
echo "Testowanie głównej pomocy:"
./citadel.sh --help | head -10

# Test pomocy specyficznej dla modułu (jeśli dostępna)
echo ""
echo "Testowanie pomocy modułu:"
./citadel.sh install help 2>/dev/null || echo "~ Pomoc install niedostępna"
./citadel.sh adblock help 2>/dev/null || echo "~ Pomoc adblock niedostępna"
```

---

## Procedury czyszczenia

### 1. Czyszczenie środowiska testowego
```bash
echo "=== CZYSZCZENIE ŚRODOWISKA TESTOWEGO ==="

# Usuń katalogi testowe
sudo rm -rf "$CYTADELA_STATE_DIR"
sudo rm -rf "$COREDNS_CONFIG_DIR"
sudo rm -rf "$DNSCRYPT_CONFIG_DIR"

# Usuń pliki testowe
rm -rf ~/cytadela-test

echo "✓ Środowisko testowe wyczyszczone"
```

### 2. Przywracanie systemu
```bash
echo "=== PRZYWRACANIE KONFIGURACJI SYSTEMU ==="

# Przywróć resolv.conf jeśli zmodyfikowany
if [[ -f /etc/resolv.conf.backup-test ]]; then
    sudo mv /etc/resolv.conf.backup-test /etc/resolv.conf
    echo "✓ resolv.conf przywrócony"
else
    echo "~ Nie znaleziono kopii zapasowej resolv.conf"
fi

# Zrestartuj usługi jeśli potrzebne
echo "Rozważ restart usług DNS:"
echo "  sudo systemctl restart systemd-resolved"
echo "  sudo systemctl restart dnscrypt-proxy"
echo "  sudo systemctl restart coredns"
```

### 3. Weryfikacja kopii zapasowej
```bash
echo "=== WERYFIKACJA KOPII ZAPASOWYCH ==="

if [[ -d /var/lib/cytadela/backups ]]; then
    echo "Dostępne kopie zapasowe:"
    ls -la /var/lib/cytadela/backups/
else
    echo "~ Nie znaleziono katalogu kopii zapasowych"
fi
```

---

## Rozwiązywanie problemów

### Częste problemy z testami

#### Błędy "Command not found"
```bash
# Sprawdź czy skrypty są wykonywalne
ls -la citadel.sh
chmod +x citadel.sh

# Sprawdź czy moduły unifikowane istnieją
ls -la modules/unified/
```

#### Błędy uprawnień
```bash
# Niektóre testy wymagają uprawnień root
echo "Testy wymagające root:"
echo "  - Sprawdzanie statusu usług"
echo "  - Dostęp do plików konfiguracyjnych"
echo "  - Zarządzanie usługami systemowymi"

# Uruchom z sudo dla testów root
sudo ./citadel.sh monitor status
```

#### Problemy z łącznością sieciową
```bash
# Sprawdź łączność sieciową
ping -c 3 8.8.8.8
curl -s https://1.1.1.1/cdn-cgi/trace | head -3

# Test rozwiązywania DNS
dig @8.8.8.8 google.com
```

#### Niepowodzenia ładowania modułów
```bash
# Sprawdź składnię modułu
bash -n modules/unified/unified-recovery.sh

# Sprawdź zależności bibliotek
ls -la lib/

# Debuguj ładowanie modułu
bash -x ./citadel.sh recovery status
```

---

## Kryteria sukcesu

### Minimalne kryteria sukcesu
- ✅ **Struktura plików:** Wszystkie pliki modułów unifikowanych istnieją i są czytelne
- ✅ **Podstawowa składnia:** Wszystkie skrypty mają prawidłową składnię bash
- ✅ **Ładowanie modułów:** Wszystkie moduły unifikowane ładują się bez krytycznych błędów
- ✅ **Kompatybilność wsteczna:** Polecenia legacy działają lub pokazują odpowiednie komunikaty
- ✅ **Dokumentacja:** Wszystkie pliki dokumentacji istnieją i są czytelne

### Pełne kryteria sukcesu
- ✅ **Wszystkie minimalne kryteria spełnione**
- ✅ **Dostępność funkcji:** Wszystkie udokumentowane funkcje są dostępne
- ✅ **Integracja:** Moduły współpracują bez konfliktów
- ✅ **Wydajność:** Ładowanie modułów < 2 sekundy
- ✅ **Użycie pamięci:** Rozsądne zużycie pamięci
- ✅ **End-to-end:** Kompletne przepływy działają prawidłowo

### Podsumowanie wyników testów
```bash
echo "=== KOŃCOWE WYNIKI TESTÓW ==="
echo "Data: $(date)"
echo "Środowisko: $(uname -a)"
echo "Tester: $(whoami)"
echo ""
echo "Zakończone kategorie testów:"
echo "  - Przygotowanie środowiska: [ ]"
echo "  - Testowanie modułów unifikowanych: [ ]"
echo "  - Kompatybilność wsteczna: [ ]"
echo "  - Funkcje krytyczne: [ ]"
echo "  - Wydajność: [ ]"
echo "  - Integracja: [ ]"
echo "  - Dokumentacja: [ ]"
echo "  - Czyszczenie: [ ]"
echo ""
echo "Ogólna ocena: [PASS/FAIL]"
echo "Gotowe do produkcji: [YES/NO]"
```

---

## Szybkie polecenia testowe

### Uruchom wszystkie testy
```bash
# Uruchom kompleksowy zestaw testów
./test/regression/test-regression.sh    # Kompatybilność wsteczna
./test/integration/test-integration.sh  # Testy integracji
```

### Indywidualne testy modułów
```bash
# Testuj specyficzne moduły
./citadel.sh recovery panic-status
./citadel.sh install check-deps
./citadel.sh security integrity-status
./citadel.sh network ipv6-privacy-status
./citadel.sh adblock status
./citadel.sh backup config-list
./citadel.sh monitor diagnostics
```

### Szybki sprawdzian zdrowia
```bash
# Szybki sprawdzian zdrowia systemu
./citadel.sh monitor status
./citadel.sh monitor verify
```

---

**Procedura testowania środowiska Cytadela v3.2**
**Ostatnia aktualizacja:** 2026-02-04
**Czas trwania testów:** 30-60 minut
**Poziom ryzyka:** Niski (z właściwą kopią zapasową i czyszczeniem)
