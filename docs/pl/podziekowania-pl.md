# 🙏 Podziękowania

Cytadela (Citadel) jest zbudowana na bazie wyjątkowych projektów open-source. Jesteśmy głęboko wdzięczni deweloperom i społecznościom stojącym za tymi narzędziami.

---

## 🔧 Główne Komponenty

### DNSCrypt-Proxy
**Projekt:** https://github.com/DNSCrypt/dnscrypt-proxy
**Licencja:** ISC License
**Opis:** Elastyczny proxy DNS z obsługą szyfrowanych protokołów DNS (DNSCrypt, DoH, Anonymized DNSCrypt i ODoH).

**Opiekunowie:** Frank Denis (@jedisct1) i współtwórcy
**Dlaczego go używamy:** DNSCrypt-Proxy zapewnia podstawę dla szyfrowanych zapytań DNS, chroniąc użytkowników przed nadzorem DNS i manipulacją.

---

### CoreDNS
**Projekt:** https://github.com/coredns/coredns
**Licencja:** Apache License 2.0
**Opis:** Szybki i elastyczny serwer DNS napisany w Go, zaprojektowany do łatwego rozszerzania wtyczkami.

**Opiekunowie:** Autorzy CoreDNS i CNCF
**Dlaczego go używamy:** CoreDNS zapewnia wysoką wydajność buforowania DNS i przekazywania z doskonałą architekturą wtyczek dla blokowania reklam i własnych stref.

---

### nftables
**Projekt:** https://git.netfilter.org/nftables/
**Licencja:** GPL-2.0
**Opis:** Następca iptables, zapewniający nowoczesną strukturę filtrowania pakietów dla Linux.

**Opiekunowie:** Zespół Netfilter Core
**Dlaczego go używamy:** nftables napędza nasz firewall ochrony przed wyciekami DNS, zapewniając że wszystkie zapytania DNS przechodzą przez nasz bezpieczny stos.

---

## 📊 Monitorowanie i Metryki

### Prometheus
**Projekt:** https://github.com/prometheus/prometheus
**Licencja:** Apache License 2.0
**Opis:** Open-source'owy system monitorowania z wielowymiarowym modelem danych i potężnym językiem zapytań.

**Opiekunowie:** Autorzy Prometheus i CNCF
**Dlaczego go używamy:** Integracja metryk Prometheus umożliwia monitorowanie w czasie rzeczywistym wydajności DNS i zdrowia systemu.

---

## 🚫 Blokowanie Reklam

### Unified Hosts Stevena Blacka
**Projekt:** https://github.com/StevenBlack/hosts
**Licencja:** MIT License
**Opis:** Konsolidacja i rozszerzanie plików hosts z kilku dobrze dobranych źródeł.

**Opiekun:** Steven Black (@StevenBlack) i współtwórcy
**Dlaczego go używamy:** Zapewnia kompleksowe, dobrze utrzymane listy blokowania dla blokowania reklam i ochrony przed malware.

### Lista Blokowania OISD
**Projekt:** https://oisd.nl/
**Licencja:** CC0 1.0 Universal
**Opis:** Najlepsza lista blokowania domen w internecie - blokuje reklamy, śledzenie, phishing, malware i więcej.

**Opiekun:** sjhgvr
**Dlaczego go używamy:** Wysokiej jakości, aktywnie utrzymywana lista blokowania z doskonałym pokryciem i niskim współczynnikiem fałszywych pozytywów.

---

## 🛠️ Narzędzia Deweloperskie

### Bash
**Projekt:** https://www.gnu.org/software/bash/
**Licencja:** GPL-3.0
**Opis:** GNU Bourne Again SHell - powłoka Unix i język poleceń.

**Opiekunowie:** Projekt GNU
**Dlaczego go używamy:** Bash zapewnia podstawę skryptową dla modularnej architektury Cytadeli.

### Gum (Charm)
**Projekt:** https://github.com/charmbracelet/gum
**Licencja:** MIT License
**Opis:** Narzędzie do glamorous shell scripts.
**Opiekunowie:** Charm (https://charm.sh)
**Dlaczego go używamy:** Gum zapewnia nasz interaktywny interfejs użytkownika terminala, zastępując tradycyjne narzędzia nowoczesnym, responsywnym doświadczeniem.

---

## 🐧 Dystrybucje Linux

### CachyOS
**Projekt:** https://cachyos.org/
**Licencja:** Różne (bazowane na Arch Linux)
**Opis:** Dystrybucja Linux bazowana na Arch Linux, skupiająca się na wydajności i łatwości użytkowania.

**Zespół:** Zespół CachyOS
**Dlaczego doceniamy:** Cytadela została opracowana i zoptymalizowana dla CachyOS, a społeczność CachyOS była niesamowicie pomocna.

### Arch Linux
**Projekt:** https://archlinux.org/
**Licencja:** Różne
**Opis:** Lekka i elastyczna dystrybucja Linux, która stara się utrzymać prostotę.

**Społeczność:** Deweloperzy i społeczność Arch Linux
**Dlaczego doceniamy:** Fundament, na którym zbudowane są CachyOS i Cytadela.

---

## 🌍 Społeczność i Inspiracja

### Pi-hole
**Projekt:** https://github.com/pi-hole/pi-hole
**Licencja:** EUPL-1.2
**Opis:** Blokujący reklamy w całej sieci, działający jako sinkhole DNS.

**Dlaczego doceniamy:** Pi-hole zapoczątkował koncepcję blokowania reklam na poziomie sieci i zainspirował wiele aspektów projektu Cytadeli.

### AdGuard Home
**Projekt:** https://github.com/AdguardTeam/AdGuardHome
**Licencja:** GPL-3.0
**Opis:** Serwer DNS blokujący reklamy i trackery w całej sieci.

**Dlaczego doceniamy:** Podejście AdGuard Home do filtrowania DNS i doświadczenia użytkownika wpłynęło na nasz zestaw funkcji.

---

## 📚 Dokumentacja i Standardy

### Autorzy RFC
Doceniamy autorów następujących RFC, które definiują standardy, które implementujemy:
- **RFC 7858** - DNS over TLS (DoT)
- **RFC 8484** - DNS Queries over HTTPS (DoH)
- **RFC 4033-4035** - Specyfikacje DNSSEC
- **RFC 1035** - Domain Names - Implementation and Specification

---

## 🤝 Szczególne Podziękowania

- **GitHub** - Za zapewnienie bezpłatnego hostingu i narzędzi współpracy dla projektów open-source
- **Wszyscy współtwórcy** - Każdy, kto zgłosił problemy, zasugerował funkcje lub przyczynił się kodem
- **Wcześni adopci** - Użytkownicy, którzy testowali Cytadelę i zapewnili cenne opinie
- **Społeczność Open Source** - Za tworzenie i utrzymywanie ekosystemu, który umożliwia projekty takie jak ten

---

## 📜 Zgodność z Licencjami

Cytadela szanuje wszystkie licencje oprogramowania, którego używa i integruje. Zapewniamy:
- Wszystkie komponenty GPL/LGPL pozostają oddzielne, a ich kod źródłowy jest dostępny
- Wszystkie komponenty licencji Apache/MIT są prawidłowo przypisane
- Wszystkie pliki licencji są zachowane w ich odpowiednich pakietach
- Żaden kod własnościowy nie jest mieszany z komponentami licencji GPL

Aby uzyskać szczegółowe informacje o licencji każdego komponentu, proszę odnieść się do ich odpowiednich repozytoriów.

---

## 💝 Jak Wspierać Te Projekty

Jeśli Cytadela była dla Ciebie przydatna, rozważ wsparcie projektów upstream:
- ⭐ Daj gwiazdkę ich repozytoriom na GitHub
- 💰 Przekaż darowiznę na ich projekty (jeśli akceptują darowizny)
- 🐛 Zgłaszaj błędy i przyczyniaj się do poprawek
- 📖 Poprawiaj ich dokumentację
- 🗣️ Rozgłaszaj informacje o ich doskonałej pracy

---

**Ostatnia aktualizacja:** 2026-02-05
**Wersja Cytadela:** v3.3.0

---

*"Jeśli widziałem dalej, to dlatego, że stałem na ramionach gigantów."* - Isaac Newton

Ten projekt nie istniałby bez niesamowitej pracy społeczności open-source. Dziękujemy wszystkim! 🙏
