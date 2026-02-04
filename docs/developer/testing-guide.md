# 🧪 Citadel - Przewodnik Testowania dla Użytkownika

## 📋 Spis Treści

1. [Testy Podstawowe (Obowiązkowe)](#testy-podstawowe)
2. [Testy Zaawansowane (Opcjonalne)](#testy-zaawansowane)
3. [Troubleshooting](#troubleshooting)
4. [Rollback (Przywracanie)](#rollback)

---

## ✅ Testy Podstawowe (Obowiązkowe)

### Test 1: Sprawdzenie instalacji

```bash
# Sprawdź czy Cytadela jest zainstalowana
which cytadela++
# Powinno zwrócić: /usr/local/bin/cytadela++

# Sprawdź wersję
sudo cytadela++ --version
# Powinno zwrócić: Citadel v3.x.x
```

**Oczekiwany wynik:** Komenda istnieje i zwraca wersję.

---

### Test 2: Sprawdzenie DNS (Podstawowy)

```bash
# Test 1: Czy DNS w ogóle działa
dig google.com @127.0.0.1 +short

# Test 2: Czy DNSSEC działa
dig sigok.verteiltesysteme.net @127.0.0.1 +dnssec +short

# Test 3: Czy blokowanie reklam działa
dig ads.google.com @127.0.0.1 +short
```

**Oczekiwane wyniki:**
- Test 1: Powinien zwrócić IP (np. `142.250.x.x`)
- Test 2: Powinien zwrócić IP + RRSIG (dowód DNSSEC)
- Test 3: Powinien zwrócić `0.0.0.0` (zablokowane)

**Co jeśli nie działa?**
```bash
# Sprawdź status usług
sudo systemctl status dnscrypt-proxy
sudo systemctl status coredns

# Sprawdź logi
sudo journalctl -u dnscrypt-proxy -n 50
sudo journalctl -u coredns -n 50
```

---

### Test 3: Sprawdzenie DNS Leak

```bash
# Test online (wymaga przeglądarki)
xdg-open https://dnsleaktest.com

# Test z terminala
dig +short txt whoami.akamai.net @127.0.0.1
```

**Oczekiwany wynik:**
- Strona dnsleaktest.com powinna pokazać tylko Twoje serwery DNS (nie ISP)
- Komenda `dig` powinna zwrócić Twoje publiczne IP

**⚠️ Jeśli widzisz DNS swojego ISP (np. Orange, Play, UPC):**
```bash
# Sprawdź czy firewall działa
sudo nft list ruleset | grep -A 5 "citadel_dns"

# Jeśli pusty output, włącz firewall:
sudo cytadela++ firewall-strict
```

---

### Test 4: Sprawdzenie Firewall

```bash
# Sprawdź czy firewall jest aktywny
sudo nft list tables

# Powinno pokazać:
# table inet citadel_dns

# Sprawdź reguły
sudo nft list table inet citadel_dns
```

**Oczekiwany wynik:**
```
table inet citadel_dns {
    chain output {
        type filter hook output priority filter; policy accept;
        # Reguły blokujące DNS leak
    }
}
```

**Co jeśli brak tabeli `citadel_dns`?**
```bash
# Włącz firewall
sudo cytadela++ firewall-strict
```

---

### Test 5: Sprawdzenie Internetu

```bash
# Test 1: Ping do Google DNS (powinien być ZABLOKOWANY)
ping -c 3 8.8.8.8
# Oczekiwany wynik: timeout lub "Destination unreachable"

# Test 2: Ping do domeny (powinien DZIAŁAĆ)
ping -c 3 google.com
# Oczekiwany wynik: odpowiedzi z IP

# Test 3: Przeglądarka
xdg-open https://www.google.com
# Oczekiwany wynik: strona się ładuje
```

**Oczekiwane wyniki:**
- ✅ Ping do IP 8.8.8.8 **NIE DZIAŁA** (firewall blokuje)
- ✅ Ping do domeny google.com **DZIAŁA** (DNS lokalny działa)
- ✅ Przeglądarka **DZIAŁA** (internet działa)

**⚠️ Jeśli internet nie działa:**
```bash
# Sprawdź czy DNS działa
dig google.com @127.0.0.1

# Sprawdź routing
ip route show

# Sprawdź czy /etc/resolv.conf wskazuje na localhost
cat /etc/resolv.conf
# Powinno być: nameserver 127.0.0.1
```

---

## 🔬 Testy Zaawansowane (Opcjonalne)

### Test 6: Performance DNS

```bash
# Benchmark DNS (wymaga dnsperf)
# Instalacja: sudo pacman -S dnsperf

# Test 1000 zapytań
echo "google.com A" > /tmp/queries.txt
dnsperf -s 127.0.0.1 -d /tmp/queries.txt -c 10 -l 10

# Sprawdź cache hit rate
sudo cytadela++ cache-stats
```

**Oczekiwany wynik:**
- Queries per second: >5000 QPS
- Cache hit rate: >80% (po kilku minutach użytkowania)

---

### Test 7: DNSSEC Validation

```bash
# Test 1: Poprawny DNSSEC (powinien działać)
dig sigok.verteiltesysteme.net @127.0.0.1

# Test 2: Zepsuty DNSSEC (powinien być ODRZUCONY)
dig sigfail.verteiltesysteme.net @127.0.0.1

# Test 3: Brak DNSSEC (powinien działać)
dig example.com @127.0.0.1
```

**Oczekiwane wyniki:**
- sigok: status NOERROR, zwraca IP
- sigfail: status SERVFAIL (odrzucone przez DNSSEC)
- example.com: status NOERROR, zwraca IP

---

### Test 8: IPv6 Support

```bash
# Test 1: Czy IPv6 DNS działa
dig google.com AAAA @::1 +short

# Test 2: Czy IPv6 leak jest zablokowany
sudo nft list table inet citadel_dns | grep -i ipv6

# Test 3: Czy privacy extensions działają
ip -6 addr show | grep "scope global temporary"
```

**Oczekiwane wyniki:**
- Test 1: Zwraca IPv6 (np. `2a00:1450:...`)
- Test 2: Pokazuje reguły blokujące IPv6 DNS leak
- Test 3: Pokazuje tymczasowe adresy IPv6 (privacy)

---

### Test 9: Adblock Effectiveness

```bash
# Test 1: Sprawdź ile domen jest zablokowanych
sudo cytadela++ adblock-stats

# Test 2: Sprawdź czy popularne domeny są zablokowane
for domain in ads.google.com doubleclick.net facebook.net; do
    echo -n "$domain: "
    dig +short $domain @127.0.0.1
done

# Test 3: Dodaj własną domenę do blokady
sudo cytadela++ adblock-add example-ads.com
dig example-ads.com @127.0.0.1 +short
# Powinno zwrócić: 0.0.0.0
```

**Oczekiwany wynik:**
- adblock-stats: >100,000 zablokowanych domen
- Wszystkie domeny reklamowe zwracają `0.0.0.0`

---

### Test 10: Stress Test

```bash
# Test obciążenia (wymaga dnsperf)
# Generuj 10,000 zapytań z 50 równoległymi klientami

cat > /tmp/queries.txt <<EOF
google.com A
youtube.com A
facebook.com A
twitter.com A
github.com A
EOF

dnsperf -s 127.0.0.1 -d /tmp/queries.txt -c 50 -l 60

# Sprawdź czy system jest stabilny
sudo systemctl status coredns dnscrypt-proxy
```

**Oczekiwany wynik:**
- Queries per second: >5000 QPS
- Usługi pozostają aktywne (status: active)
- Brak błędów w logach

---

## 🔧 Troubleshooting

### Problem: Internet nie działa po instalacji

**Diagnoza:**
```bash
# 1. Sprawdź czy DNS działa
dig google.com @127.0.0.1

# 2. Sprawdź /etc/resolv.conf
cat /etc/resolv.conf

# 3. Sprawdź usługi
sudo systemctl status coredns dnscrypt-proxy
```

**Rozwiązanie:**
```bash
# Jeśli DNS nie działa:
sudo systemctl restart dnscrypt-proxy coredns

# Jeśli /etc/resolv.conf jest zły:
sudo cytadela++ configure-system

# Jeśli nadal nie działa, przywróć system:
sudo cytadela++ restore-system
```

---

### Problem: DNS leak (widzę DNS mojego ISP)

**Diagnoza:**
```bash
# Sprawdź firewall
sudo nft list ruleset | grep -A 10 "citadel_dns"
```

**Rozwiązanie:**
```bash
# Włącz strict mode
sudo cytadela++ firewall-strict

# Sprawdź ponownie
dig +short txt whoami.akamai.net @127.0.0.1
```

---

### Problem: Niektóre strony nie działają

**Diagnoza:**
```bash
# Sprawdź czy to problem z adblockiem
dig problematic-domain.com @127.0.0.1

# Jeśli zwraca 0.0.0.0, domena jest zablokowana
```

**Rozwiązanie:**
```bash
# Dodaj domenę do whitelist
sudo cytadela++ allowlist-add problematic-domain.com

# Sprawdź ponownie
dig problematic-domain.com @127.0.0.1
```

---

### Problem: Wolny DNS

**Diagnoza:**
```bash
# Sprawdź cache stats
sudo cytadela++ cache-stats

# Sprawdź upstream latency
dig google.com @127.0.0.1 | grep "Query time"
```

**Rozwiązanie:**
```bash
# Jeśli cache hit rate < 50%, poczekaj kilka minut
# Jeśli Query time > 100ms, sprawdź upstream:

# 1. Sprawdź DNSCrypt logi
sudo journalctl -u dnscrypt-proxy -n 100 | grep -i "error\|timeout"

# 2. Zmień upstream (opcjonalnie)
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml
# Zmień server_names na szybsze serwery
sudo systemctl restart dnscrypt-proxy
```

---

## 🔄 Rollback (Przywracanie)

### Przywracanie systemu do stanu sprzed Cytadeli

```bash
# Krok 1: Przywróć DNS systemu
sudo cytadela++ restore-system

# Krok 2: Sprawdź czy internet działa
ping -c 3 google.com

# Krok 3: (Opcjonalnie) Usuń Cytadelę
sudo systemctl stop coredns dnscrypt-proxy
sudo systemctl disable coredns dnscrypt-proxy
sudo rm -rf /opt/cytadela
sudo rm /usr/local/bin/cytadela++
```

**⚠️ Uwaga:** Po `restore-system` Cytadela nadal jest zainstalowana, ale DNS wraca do systemd-resolved.

---

## 📊 Checklist Testów

Przed uznaniem instalacji za udaną, upewnij się że:

- [ ] `dig google.com @127.0.0.1` zwraca IP
- [ ] `dig ads.google.com @127.0.0.1` zwraca `0.0.0.0`
- [ ] https://dnsleaktest.com nie pokazuje DNS ISP
- [ ] `ping 8.8.8.8` jest zablokowany (timeout)
- [ ] `ping google.com` działa
- [ ] Przeglądarka ładuje strony
- [ ] `sudo nft list tables` pokazuje `citadel_dns`
- [ ] `sudo systemctl status coredns` pokazuje `active (running)`
- [ ] `sudo systemctl status dnscrypt-proxy` pokazuje `active (running)`

**Jeśli wszystkie checkboxy są zaznaczone: ✅ Cytadela działa poprawnie!**

---

## 🆘 Pomoc

Jeśli żaden z powyższych testów nie pomógł:

1. **Sprawdź logi:**
   ```bash
   sudo journalctl -u coredns -n 100
   sudo journalctl -u dnscrypt-proxy -n 100
   ```

2. **Zgłoś issue na GitHub:**
   https://github.com/QguAr71/Cytadela/issues

3. **Przywróć system:**
   ```bash
   sudo cytadela++ restore-system
   ```

---

## 📝 Notatki

- Wszystkie testy powinny być wykonane **po instalacji** i **po restarcie systemu**
- Jeśli test nie przechodzi, **nie panikuj** - użyj `restore-system`
- Cache DNS potrzebuje kilku minut aby się "rozgrzać" (zwiększyć hit rate)
- Firewall STRICT może blokować niektóre aplikacje (VPN, Tor) - użyj SAFE mode jeśli potrzebne

---

**Wersja dokumentu:** 1.0  
**Data:** 2026-01-30  
**Dla Citadel v3.2.0+**
