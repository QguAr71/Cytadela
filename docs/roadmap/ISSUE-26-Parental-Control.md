# Issue #26 - Parental Control

**Wersja:** v3.3  
**Priorytet:** Średni  
**Effort:** ~10-15h  
**Status:** Planned (Q2 2026)

---

## 📋 Opis

Kontrola rodzicielska dla Citadel - możliwość zarządzania dostępem do internetu dla dzieci i nastolatków.

---

## 🎯 Cele

1. Profile dla różnych grup wiekowych (Kids, Teens)
2. Harmonogramy czasowe (internet 8-20, weekendy)
3. Blokowanie kategorii (adult, gambling, social media, gaming)
4. Raporty aktywności (dzienne/tygodniowe)
5. Łatwe zarządzanie przez CLI

---

## 🔧 Funkcjonalność

### Profile użytkowników

```bash
# Dodaj profil dziecka
sudo citadel.sh parental-add "Janek" --age 10 --mac AA:BB:CC:DD:EE:FF

# Ustaw profil
sudo citadel.sh parental-set "Janek" --profile kids
```

### Harmonogramy czasowe

```bash
# Ustaw godziny dostępu
sudo citadel.sh parental-schedule "Janek" --weekdays 15:00-20:00 --weekends 10:00-22:00

# Blokuj internet w nocy
sudo citadel.sh parental-schedule "Janek" --bedtime 21:00-07:00
```

### Blokowanie kategorii

```bash
# Zablokuj kategorie
sudo citadel.sh parental-block "Janek" --categories adult,gambling,social-media

# Lista dostępnych kategorii
sudo citadel.sh parental-categories
```

### Raporty

```bash
# Raport dzienny
sudo citadel.sh parental-report "Janek" --daily

# Raport tygodniowy
sudo citadel.sh parental-report "Janek" --weekly

# Top odwiedzane domeny
sudo citadel.sh parental-report "Janek" --top-domains 20
```

---

## 🏗️ Implementacja

### Nowy moduł: `modules/parental-control.sh`

**Funkcje:**
- `parental_add()` - dodaj profil dziecka
- `parental_set()` - ustaw profil (kids/teens/custom)
- `parental_schedule()` - zarządzanie harmonogramem
- `parental_block()` - blokowanie kategorii
- `parental_report()` - generowanie raportów
- `parental_list()` - lista profili
- `parental_remove()` - usuń profil

### Integracja z NFTables

```bash
# Reguły NFTables per MAC address
nft add rule inet citadel filter_forward ether saddr AA:BB:CC:DD:EE:FF meta hour 21-07 drop

# Blokowanie kategorii przez CoreDNS zones
/etc/coredns/zones/parental-adult.hosts
/etc/coredns/zones/parental-gambling.hosts
/etc/coredns/zones/parental-social.hosts
```

### Baza danych profili

```bash
# /var/lib/citadel/parental/profiles.json
{
  "Janek": {
    "age": 10,
    "profile": "kids",
    "mac": "AA:BB:CC:DD:EE:FF",
    "schedule": {
      "weekdays": "15:00-20:00",
      "weekends": "10:00-22:00",
      "bedtime": "21:00-07:00"
    },
    "blocked_categories": ["adult", "gambling", "social-media"],
    "created": "2026-02-01",
    "last_modified": "2026-02-15"
  }
}
```

---

## 📊 Profile domyślne

### Kids (6-12 lat)
- Blokowane: adult, gambling, social-media, dating, weapons
- Czas: 15:00-20:00 (weekdays), 10:00-21:00 (weekends)
- Safe search: wymuszony

### Teens (13-17 lat)
- Blokowane: adult, gambling, dating
- Czas: 14:00-22:00 (weekdays), 09:00-23:00 (weekends)
- Safe search: zalecany

### Custom
- Użytkownik definiuje wszystko

---

## 🔐 Bezpieczeństwo

- Profile chronione hasłem (opcjonalnie)
- Logi zmian w `/var/log/citadel/parental.log`
- Powiadomienia o próbach obejścia
- Backup profili przy każdej zmianie

---

## 📚 Kategorie blokad

**Dostępne kategorie:**
- `adult` - treści dla dorosłych
- `gambling` - hazard, zakłady
- `social-media` - Facebook, Instagram, TikTok, etc.
- `gaming` - gry online, platformy gamingowe
- `dating` - portale randkowe
- `weapons` - broń, przemoc
- `drugs` - narkotyki, alkohol
- `violence` - przemoc, gore

**Źródła list:**
- Shallalist
- UT1 Blacklist
- Custom lists

---

## 🧪 Testowanie

```bash
# Test profilu
sudo citadel.sh parental-test "Janek"

# Symulacja dostępu
sudo citadel.sh parental-simulate "Janek" --domain facebook.com --time 16:00

# Weryfikacja reguł NFTables
sudo citadel.sh parental-verify "Janek"
```

---

## 📝 Dokumentacja

- User guide: `docs/user/parental-control.md`
- Examples: `docs/user/parental-examples.md`
- FAQ: Dodać sekcję do `docs/user/faq.md`

---

## 🎯 Milestone

**v3.3 (Q2 2026)**
- [ ] Moduł parental-control.sh
- [ ] Integracja z NFTables
- [ ] Baza danych profili
- [ ] Profile domyślne (Kids, Teens)
- [ ] Kategorie blokad (8 kategorii)
- [ ] Raporty aktywności
- [ ] Dokumentacja
- [ ] Testy

---

**Effort:** ~10-15h  
**Zależności:** Gateway Mode (v3.2) - opcjonalnie, działa też standalone
