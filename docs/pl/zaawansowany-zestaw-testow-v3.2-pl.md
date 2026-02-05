# 🧪 Zaawansowany Zestaw Testów - Plan v3.2

**Wersja:** 3.2.0 PLANOWANA
**Utworzono:** 2026-02-01
**Status:** Faza planowania
**Priorytet:** Średni

---

## 📋 Przegląd

Ten dokument opisuje zaawansowany zestaw testów planowany dla v3.2, adresujący ograniczenia zidentyfikowane w testowaniu v3.1.0. Celem jest zapewnienie kompleksowego, zautomatyzowanego testowania, które pokrywa przypadki brzegowe, scenariusze obciążenia i długoterminową stabilność.

**Aktualny Stan (v3.1.0):**
- ✅ 7 podstawowych testów (DNS leak, odzyskiwanie po awarii, backup/restore, DNSSEC, IPv6, blokowanie malware, wydajność)
- ✅ Testowanie manualne z udokumentowanymi wynikami
- ⚠️ Brak: Przypadki brzegowe, testowanie obciążenia, długoterminowa stabilność, automatyzacja

**Docelowy Stan (v3.2):**
- ✅ Wszystkie testy v3.1.0 zautomatyzowane
- ✅ Pokrycie przypadków brzegowych (DDoS, interferencje, fałszywe pozytywy)
- ✅ Testy długoterminowej stabilności (24h+)
- ✅ Integracja CI/CD
- ✅ Detekcja regresji

---

## 🎯 Kategorie Testów

### 1. Wysokie Obciążenie / Symulacja DDoS

**Aktualna Luka:**
- v3.1.0 testował normalne obciążenie (76K QPS utrzymane, 30s)
- Brak: Ekstremalne obciążenie, ataki flood, walidacja rate limiting

**Planowane Testy:**

#### 1.1 Symulacja Ataku Flood
```bash
# hping3 DNS flood
sudo hping3 -2 -p 53 --flood 127.0.0.1

# Oczekiwane zachowanie:
# - Rate limiting włącza się (limit 10 QPS)
# - Logi pokazują wpisy "CITADEL DNS LEAK"
# - Usługa pozostaje responsywna
# - Brak awarii lub wycieku pamięci
```

#### 1.2 Utrzymane Wysokie Obciążenie (60s+)
```bash
# dnsperf z 500 równoległymi klientami, czas trwania 300s
dnsperf -s 127.0.0.1 -d queries.txt -c 500 -l 300

# Oczekiwane metryki:
# - QPS: 50K+ utrzymane
# - Straty pakietów: <1%
# - Opóźnienie: <5ms średnie
# - Pamięć: Stabilna (bez wycieków)
```

#### 1.3 Atak Amplifikacji Zapytania
```bash
# Duże zapytania DNS (EDNS0, rekordy ANY)
dig @127.0.0.1 . ANY +bufsize=4096

# Oczekiwane zachowanie:
# - Właściwa obsługa EDNS0
# - Brak podatności na amplifikację
# - Rate limiting stosowane
```

**Wymagane Narzędzia:**
- hping3
- dnsperf
- mz (Mausezahn)
- Niestandardowe skrypty flood

**Kryteria Sukcesu:**
- ✅ Usługa przetrwa ataki flood
- ✅ Rate limiting działa prawidłowo
- ✅ Logi rejestrują próby ataków
- ✅ Brak wycieków pamięci pod obciążeniem
- ✅ Czas odzyskiwania <30s po zatrzymaniu ataku

---

### 2. Interferencje DNSSEC + Adblock

**Aktualna Luka:**
- DNSSEC i adblock testowane osobno
- Brak: Testowanie interakcji, zablokowane domeny DNSSEC

**Planowane Testy:**

#### 2.1 Domeny Zablokowane Podpisane DNSSEC
```bash
# Test domen które są:
# 1. Podpisane DNSSEC
# 2. Na liście blokowania

# Oczekiwane zachowanie:
# - Domena zablokowana (0.0.0.0)
# - Brak błędu walidacji DNSSEC
# - Właściwe logowanie
```

#### 2.2 Walidacja DNSSEC z Włączonym Adblock
```bash
# Test wielu domen podpisanych DNSSEC
dig @127.0.0.1 icann.org +dnssec
dig @127.0.0.1 ietf.org +dnssec
dig @127.0.0.1 ripe.net +dnssec

# Oczekiwane:
# - Flaga AD obecna
# - Rekordy RRSIG obecne
# - Brak interferencji z adblock
```

#### 2.3 Nieprawidłowy DNSSEC z Adblock
```bash
# Test nieprawidłowego podpisu DNSSEC
dig @127.0.0.1 dnssec-failed.org

# Oczekiwane:
# - SERVFAIL (błąd walidacji DNSSEC)
# - Nie zablokowane przez adblock (walidacja dzieje się najpierw)
```

**Kryteria Sukcesu:**
- ✅ Walidacja DNSSEC działa z włączonym adblock
- ✅ Zablokowane domeny nie wywołują błędów DNSSEC
- ✅ Nieprawidłowe podpisy prawidłowo odrzucane
- ✅ Brak fałszywych pozytywów w walidacji DNSSEC

---

### 3. Długoterminowa Stabilność

**Aktualna Luka:**
- Tylko krótkoterminowe testy (30s-60s)
- Brak: Wycieki pamięci, wyczerpanie zasobów, utrzymane obciążenie

**Planowane Testy:**

#### 3.1 Test Wycieku Pamięci 24-Godziny
```bash
# Monitoruj zużycie pamięci przez 24h
while true; do
    echo "$(date): $(ps aux | grep -E 'coredns|dnscrypt' | awk '{print $6}')" >> memory.log
    sleep 60
done

# Oczekiwane:
# - Zużycie pamięci stabilne (±5%)
# - Brak ciągłego wzrostu
# - RSS < 200MB dla CoreDNS
# - RSS < 100MB dla DNSCrypt-Proxy
```

#### 3.2 Utrzymane Obciążenie (24h)
```bash
# Uruchom dnsperf przez 24 godziny
dnsperf -s 127.0.0.1 -d queries.txt -c 100 -l 86400

# Oczekiwane:
# - QPS stabilne przez cały czas
# - Brak degradacji z czasem
# - 0% strat pakietów
# - Opóźnienie konsekwentne
```

#### 3.3 Test Obciążenia Odzyskiwania po Awarii
```bash
# Zabijaj usługi wielokrotnie przez 24h
for i in {1..100}; do
    sudo killall -9 coredns dnscrypt-proxy
    sleep 300  # Czekaj 5 minut
done

# Oczekiwane:
# - Auto-restart za każdym razem
# - Czas odzyskiwania <30s
# - Brak permanentnych awarii
# - Logi pokazują wszystkie restarty
```

**Monitorowanie:**
- Zużycie pamięci (RSS, VSZ)
- Zużycie CPU
- Deskryptory plików
- Połączenia sieciowe
- I/O dyskowe
- Współczynnik trafień cache

**Kryteria Sukcesu:**
- ✅ Pamięć stabilna przez 24h (±5%)
- ✅ Brak wyczerpania zasobów
- ✅ Wydajność konsekwentna
- ✅ Auto-odzyskiwanie działa 100% czasu

---

### 4. Rozszerzenia Prywatności IPv6

**Aktualna Luka:**
- Ochrona przed wyciekami IPv6 testowana
- Brak: Rozszerzenia prywatności, tymczasowe adresy

**Planowane Testy:**

#### 4.1 Walidacja Tymczasowych Adresów
```bash
# Sprawdź tymczasowe adresy IPv6
ip -6 addr show | grep "scope global temporary"

# Oczekiwane:
# - Co najmniej jeden tymczasowy adres obecny
# - Rozszerzenia prywatności włączone
# - Adresy rotują okresowo
```

#### 4.2 Konfiguracja Rozszerzeń Prywatności
```bash
# Zweryfikuj ustawienia sysctl
sysctl net.ipv6.conf.all.use_tempaddr
sysctl net.ipv6.conf.default.use_tempaddr

# Oczekiwane:
# - use_tempaddr = 2 (preferuj tymczasowe)
# - temp_valid_lft skonfigurowane
# - temp_prefered_lft skonfigurowane
```

#### 4.3 Wyciek DNS IPv6 z Rozszerzeniami Prywatności
```bash
# Test wycieku DNS z tymczasowymi adresami
dig @2001:4860:4860::8888 google.com AAAA +time=2

# Oczekiwane:
# - Timeout (zablokowane przez firewall)
# - Brak wycieku przez tymczasowe adresy
# - Logi pokazują zablokowaną próbę
```

**Kryteria Sukcesu:**
- ✅ Tymczasowe adresy obecne
- ✅ Rozszerzenia prywatności włączone
- ✅ Brak wycieków DNS IPv6
- ✅ Rotacja adresów działa

---

### 5. Fałszywe Pozytywy Adblock

**Aktualna Luka:**
- Tylko domeny malware testowane
- Brak: Weryfikacja legalnych stron

**Planowane Testy:**

#### 5.1 Test Top 100 Stron
```bash
# Test top 100 stron Alexa/Tranco
for site in $(cat top100.txt); do
    result=$(dig @127.0.0.1 "$site" +short)
    if [[ "$result" == "0.0.0.0" ]]; then
        echo "FAŁSZYWA POZYTYWNA: $site"
    fi
done

# Oczekiwane:
# - 0 fałszywych pozytywów
# - Wszystkie legalne strony rozwiązują się
```

#### 5.2 CDN i Usługi Chmurowe
```bash
# Test głównych CDN (nigdy nie powinny być blokowane)
dig @127.0.0.1 cloudflare.com
dig @127.0.0.1 akamai.com
dig @127.0.0.1 fastly.com
dig @127.0.0.1 cloudfront.net

# Oczekiwane:
# - Wszystkie rozwiązują się prawidłowo
# - Brak fałszywych bloków
```

#### 5.3 Narzędzia Deweloperskie
```bash
# Test stron deweloperskich (krytyczne dla użytkowników)
dig @127.0.0.1 github.com
dig @127.0.0.1 stackoverflow.com
dig @127.0.0.1 gitlab.com
dig @127.0.0.1 npmjs.com
dig @127.0.0.1 pypi.org

# Oczekiwane:
# - Wszystkie rozwiązują się prawidłowo
# - Brak interferencji z developmentem
```

**Automatyczny Test:**
```bash
# Dodane do tests/smoke-test.sh (TEST 8)
test_adblock_false_positives() {
    # Testuje 8 legalnych stron
    # Zawodzi jeśli jakakolwiek zablokowana
}
```

**Kryteria Sukcesu:**
- ✅ 0 fałszywych pozytywów w top 100 stron
- ✅ CDN nigdy nie blokowane
- ✅ Narzędzia deweloperskie dostępne
- ✅ Automatyczny test w smoke-test.sh

---

### 6. Dodatkowe Domeny DNSSEC

**Aktualna Luka:**
- Tylko 2 domeny testowane (cloudflare-dns.com, dnssec-failed.org)
- Brak: Szersze pokrycie DNSSEC

**Planowane Testy:**

#### 6.1 Podpisana Strefa Root
```bash
dig @127.0.0.1 . DNSKEY +dnssec

# Oczekiwane:
# - Rekordy DNSKEY obecne
# - RRSIG obecne
# - Flaga AD ustawiona
```

#### 6.2 Główne Organizacje
```bash
# Test domen podpisanych DNSSEC
dig @127.0.0.1 icann.org +dnssec
dig @127.0.0.1 ietf.org +dnssec
dig @127.0.0.1 ripe.net +dnssec
dig @127.0.0.1 iana.org +dnssec

# Oczekiwane:
# - Wszystkie pokazują flagę AD
# - Rekordy RRSIG obecne
# - Walidacja udana
```

#### 6.3 DNSSEC TLD
```bash
# Test DNSSEC TLD
dig @127.0.0.1 se. DNSKEY +dnssec  # Sweden
dig @127.0.0.1 nl. DNSKEY +dnssec  # Netherlands
dig @127.0.0.1 cz. DNSKEY +dnssec  # Czech Republic

# Oczekiwane:
# - DNSSEC TLD działa
# - Łańcuch zaufania zweryfikowany
```

**Kryteria Sukcesu:**
- ✅ Strefa root DNSSEC zweryfikowana
- ✅ 10+ podpisanych domen przetestowanych
- ✅ DNSSEC TLD działa
- ✅ Łańcuch zaufania zweryfikowany

---

## 🤖 Integracja CI/CD

**Cel:** Zautomatyzować wszystkie testy w GitHub Actions

### Struktura Workflow

```yaml
name: Advanced Testing Suite

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 2 * * *'  # Codziennie o 2 AM

jobs:
  smoke-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run smoke tests
        run: ./tests/smoke-test.sh
  
  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Install dependencies
        run: sudo apt-get install -y dnsperf bind9-dnsutils
      - name: Run performance benchmark
        run: ./tests/performance-test.sh
      - name: Check regression
        run: ./tests/check-regression.sh
  
  stress-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Install stress tools
        run: sudo apt-get install -y hping3
      - name: Run stress tests
        run: ./tests/stress-test.sh
  
  dnssec-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Run DNSSEC validation
        run: ./tests/dnssec-test.sh
```

### Skrypty Testowe do Utworzenia

1. **tests/performance-test.sh** - Zautomatyzowane benchmarki wydajności
2. **tests/stress-test.sh** - Symulacja DDoS i wysokie obciążenie
3. **tests/dnssec-test.sh** - Kompleksowa walidacja DNSSEC
4. **tests/check-regression.sh** - Porównanie z metrykami bazowymi
5. **tests/long-term-test.sh** - Stabilność 24h (manual trigger)

---

## 📊 Metryki i Raportowanie

### Linia Bazowa Wydajności (v3.1.0)

```yaml
baseline:
  qps: 76323
  latency_avg: 1.29ms
  latency_min: 0.01ms
  latency_max: 202ms
  packet_loss: 0%
  cache_hit_rate: 99.99%
```

### Detekcja Regresji

```bash
# Porównaj aktualny przebieg z bazowym
if [[ $current_qps -lt $((baseline_qps * 90 / 100)) ]]; then
    echo "REGRESJA: QPS spadło o >10%"
    exit 1
fi
```

### Raporty Testów

- **Format:** Markdown + JSON
- **Przechowywanie:** `tests/reports/`
- **Artefakty:** Artefakty GitHub Actions
- **Powiadomienia:** Slack/Discord przy awariach

---

## 🗓️ Harmonogram Implementacji

### Faza 1: Skrypty Testowe (Tydzień 1-2)
- [ ] Utwórz performance-test.sh
- [ ] Utwórz stress-test.sh
- [ ] Utwórz dnssec-test.sh
- [ ] Utwórz check-regression.sh
- [ ] Zaktualizuj smoke-test.sh (już wykonane)

### Faza 2: Integracja CI/CD (Tydzień 3)
- [ ] Utwórz workflow GitHub Actions
- [ ] Skonfiguruj środowisko testowe
- [ ] Skonfiguruj artefakty i raportowanie
- [ ] Dodaj detekcję regresji

### Faza 3: Długoterminowe Testy (Tydzień 4)
- [ ] Utwórz test stabilności 24h
- [ ] Skonfiguruj monitorowanie (Prometheus/Grafana)
- [ ] Udokumentuj procedury testowania manualnego
- [ ] Utwórz szablony raportów testowych

### Faza 4: Dokumentacja (Tydzień 5)
- [ ] Zaktualizuj szablon TESTING-RESULTS
- [ ] Utwórz przewodnik wykonania testów
- [ ] Udokumentuj konfigurację CI/CD
- [ ] Dodaj przewodnik rozwiązywania problemów

---

## ✅ Kryteria Sukcesu

**Zaawansowany Zestaw Testów v3.2 jest kompletny gdy:**

1. ✅ Wszystkie 6 kategorii testów zaimplementowane
2. ✅ Workflow CI/CD działa przy każdym PR
3. ✅ Detekcja regresji aktywna
4. ✅ Test stabilności 24h udokumentowany
5. ✅ Pokrycie testami >90%
6. ✅ Wszystkie testy zautomatyzowane (oprócz 24h)
7. ✅ Dokumentacja kompletna

---

## 🔗 Powiązane Dokumenty

- [TESTING-RESULTS-2026-02-01.md](TESTING-RESULTS-2026-02-01.md) - wyniki testów v3.1.0
- [REFACTORING-V3.2-PLAN.md](REFACTORING-V3.2-PLAN.md) - plan refaktoryzacji v3.2
- [tests/smoke-test.sh](../tests/smoke-test.sh) - aktualne testy smoke

---

**Status:** Faza planowania
**Docelowe Wydanie:** v3.2.0
**Priorytet:** Średni
**Szacowany Nakład:** 5 tygodni
