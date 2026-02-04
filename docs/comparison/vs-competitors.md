# CYTADELA++ vs KONKURENCJA - PORÓWNANIE

**Data:** 2026-01-30  
**Wersja:** v3.1.0 (obecna) + v3.2 Gateway Mode (planowana)  
**Dla:** Użytkownicy domowi i małe firmy

---

## 🎯 KONKURENCJA

### **Główni gracze:**
1. **Pi-hole** - najpopularniejszy DNS adblock
2. **AdGuard Home** - komercyjny (open-source)
3. **pfSense** - pełny firewall/router
4. **OPNsense** - fork pfSense
5. **Tylko DNSCrypt** - minimalistyczne podejście

---

## 📊 PORÓWNANIE SZCZEGÓŁOWE

### **1. CYTADELA++ v3.1 (OBECNA)**

| Funkcja | Citadel | Pi-hole | AdGuard Home | pfSense | DNSCrypt |
|---------|------------|---------|--------------|---------|----------|
| **DNS Encryption** | ✅ DNSCrypt/DoH | ❌ | ✅ DoH/DoT | ✅ | ✅ |
| **Adblock** | ✅ 1.2M domen | ✅ | ✅ | ⚠️ plugin | ❌ |
| **DNS Leak Prevention** | ✅ NFTables | ⚠️ częściowo | ⚠️ częściowo | ✅ | ❌ |
| **Cache** | ✅ CoreDNS | ✅ | ✅ | ✅ | ❌ |
| **Modułowa architektura** | ✅ | ❌ | ❌ | ⚠️ | ❌ |
| **Multi-blocklist** | ✅ 6 profili | ⚠️ ręcznie | ✅ | ❌ | ❌ |
| **Auto-update** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Backup/Restore** | ✅ 1 komenda | ⚠️ ręcznie | ✅ | ✅ | ❌ |
| **Cache Stats** | ✅ Prometheus | ✅ | ✅ | ✅ | ❌ |
| **Desktop Notifications** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Interactive Installer** | ✅ | ❌ | ❌ | ✅ | ❌ |
| **CLI** | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| **Web UI** | ❌ (v3.4) | ✅ | ✅ | ✅ | ❌ |
| **Wymagania RAM** | 512 MB | 512 MB | 512 MB | 1 GB | 256 MB |
| **Instalacja** | 5 min | 5 min | 5 min | 30 min | 2 min |
| **Krzywa uczenia** | Średnia | Łatwa | Łatwa | Wysoka | Wysoka |

### **Ocena v3.1:**
- **Ochrona DNS:** ⭐⭐⭐⭐⭐ (najlepsza - DNSCrypt + leak prevention)
- **Adblock:** ⭐⭐⭐⭐⭐ (równy z Pi-hole/AdGuard)
- **Łatwość użycia:** ⭐⭐⭐⭐ (dobra - interactive installer, brak GUI)
- **Funkcjonalność:** ⭐⭐⭐⭐⭐ (modułowa, elastyczna)
- **Prywatność:** ⭐⭐⭐⭐⭐ (najlepsza - local-first, no telemetry)

---

### **2. CYTADELA++ v3.2 + GATEWAY MODE (PLANOWANA)**

| Funkcja | Citadel v3.2 | Pi-hole | AdGuard Home | pfSense | OPNsense |
|---------|-----------------|---------|--------------|---------|----------|
| **Wszystko z v3.1** | ✅ | - | - | - | - |
| **Network Gateway** | ✅ | ❌ | ❌ | ✅ | ✅ |
| **DHCP Server** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **NAT/Routing** | ✅ | ❌ | ❌ | ✅ | ✅ |
| **Per-device Stats** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Parental Control** | ✅ | ⚠️ plugin | ✅ | ✅ | ✅ |
| **Device Blocking** | ✅ | ⚠️ ręcznie | ✅ | ✅ | ✅ |
| **Time Schedules** | ✅ | ❌ | ✅ | ✅ | ✅ |
| **Terminal UI (TUI)** | ✅ | ❌ | ❌ | ✅ | ✅ |
| **Web UI** | ⚠️ opcjonalnie | ✅ | ✅ | ✅ | ✅ |
| **VPN Server** | ❌ (v3.3?) | ⚠️ plugin | ❌ | ✅ | ✅ |
| **IDS/IPS** | ❌ (v3.2+) | ❌ | ❌ | ✅ | ✅ |
| **Wymagania RAM** | 2 GB | 512 MB | 512 MB | 2 GB | 2 GB |
| **Wymagania CPU** | Pentium 4+ | Raspberry Pi | Raspberry Pi | Core i3+ | Core i3+ |
| **Instalacja** | 10 min | 5 min | 5 min | 60 min | 60 min |
| **Krzywa uczenia** | Średnia | Łatwa | Łatwa | Wysoka | Wysoka |
| **Koszt sprzętu** | 150-300 zł | 400 zł (RPi) | 400 zł (RPi) | 500+ zł | 500+ zł |

### **Ocena v3.2 (z Gateway):**
- **Ochrona DNS:** ⭐⭐⭐⭐⭐ (najlepsza)
- **Adblock:** ⭐⭐⭐⭐⭐ (równy z konkurencją)
- **Gateway/Routing:** ⭐⭐⭐⭐ (dobry - nie pełny firewall jak pfSense)
- **Łatwość użycia:** ⭐⭐⭐⭐ (TUI + wizard)
- **Funkcjonalność:** ⭐⭐⭐⭐⭐ (bardzo bogata)
- **Prywatność:** ⭐⭐⭐⭐⭐ (najlepsza)
- **Koszt:** ⭐⭐⭐⭐⭐ (najtańszy - stary PC)

---

## 🏆 PRZEWAGI CYTADELA++ (v3.2)

### **1. Bezpieczeństwo DNS**
| | Citadel | Pi-hole | AdGuard | pfSense |
|-|------------|---------|---------|---------|
| Szyfrowanie DNS | ✅ DNSCrypt/DoH | ❌ | ✅ DoH/DoT | ✅ |
| Leak prevention | ✅ NFTables strict | ⚠️ częściowo | ⚠️ częściowo | ✅ |
| Local-first | ✅ | ⚠️ częściowo | ❌ telemetry | ✅ |
| Supply-chain verify | ✅ | ❌ | ❌ | ⚠️ |

**Werdykt:** 🥇 **Citadel wygrywa** - jedyna z pełnym DNSCrypt + strict leak prevention

### **2. Adblock**
| | Citadel | Pi-hole | AdGuard | pfSense |
|-|------------|---------|---------|---------|
| Liczba domen | 1.2M (balanced) | ~1M | ~1M | ⚠️ plugin |
| Multi-blocklist | ✅ 6 profili | ⚠️ ręcznie | ✅ | ❌ |
| Allowlist | ✅ | ✅ | ✅ | ❌ |
| Custom rules | ✅ | ✅ | ✅ | ⚠️ |

**Werdykt:** 🥈 **Remis z Pi-hole/AdGuard** - wszystkie równie dobre

### **3. Łatwość użycia**
| | Citadel | Pi-hole | AdGuard | pfSense |
|-|------------|---------|---------|---------|
| Instalacja | 10 min (wizard) | 5 min | 5 min | 60 min |
| Interface | TUI + CLI | Web UI | Web UI | Web UI |
| Dokumentacja PL | ✅ | ❌ | ⚠️ częściowo | ❌ |
| Krzywa uczenia | Średnia | Łatwa | Łatwa | Wysoka |

**Werdykt:** 🥈 **Pi-hole/AdGuard łatwiejsze** (Web UI), ale Citadel ma TUI + PL docs

### **4. Funkcjonalność**
| | Citadel | Pi-hole | AdGuard | pfSense |
|-|------------|---------|---------|---------|
| Modułowa | ✅ | ❌ | ❌ | ⚠️ |
| Gateway | ✅ (v3.2) | ❌ | ❌ | ✅ |
| Parental control | ✅ (v3.3) | ⚠️ plugin | ✅ | ✅ |
| Backup/Restore | ✅ 1 cmd | ⚠️ ręcznie | ✅ | ✅ |
| Auto-update | ✅ all | ✅ blocklist | ✅ | ✅ |

**Werdykt:** 🥇 **Citadel wygrywa** - najbardziej modułowa i elastyczna

### **5. Prywatność**
| | Citadel | Pi-hole | AdGuard | pfSense |
|-|------------|---------|---------|---------|
| Telemetria | ❌ zero | ❌ zero | ⚠️ opcjonalna | ❌ zero |
| Local-first | ✅ | ✅ | ⚠️ | ✅ |
| Open-source | ✅ | ✅ | ✅ | ✅ |
| Supply-chain | ✅ verify | ❌ | ❌ | ⚠️ |

**Werdykt:** 🥇 **Citadel wygrywa** - zero telemetry + supply-chain verification

### **6. Koszt**
| | Citadel | Pi-hole | AdGuard | pfSense |
|-|------------|---------|---------|---------|
| Sprzęt | 150-300 zł (stary PC) | 400 zł (RPi 4) | 400 zł (RPi 4) | 500+ zł |
| Prąd/rok | 140-210 zł | 50 zł | 50 zł | 200+ zł |
| **Total/rok** | **290-510 zł** | **450 zł** | **450 zł** | **700+ zł** |

**Werdykt:** 🥇 **Citadel wygrywa** - najtańszy (stary PC za 150 zł)

---

## 🎯 POZYCJONOWANIE NA RYNKU

### **Citadel v3.2 (z Gateway) to:**

**Hybryda między:**
- **Pi-hole** (adblock) + **pfSense** (gateway) + **DNSCrypt** (privacy)

**Dla kogo:**
- ✅ Użytkownicy domowi (rodzina, smart home)
- ✅ Privacy-conscious users
- ✅ Małe firmy (5-20 urządzeń)
- ✅ Tech enthusiasts
- ❌ Duże firmy (lepiej pfSense/OPNsense)
- ❌ Użytkownicy którzy MUSZĄ mieć Web UI

---

## 📊 TABELA KOŃCOWA - OCENY

| Kategoria | Citadel v3.2 | Pi-hole | AdGuard | pfSense |
|-----------|-----------------|---------|---------|---------|
| **Bezpieczeństwo DNS** | 🥇 10/10 | 6/10 | 7/10 | 9/10 |
| **Adblock** | 🥈 10/10 | 10/10 | 10/10 | 5/10 |
| **Łatwość użycia** | 🥈 8/10 | 10/10 | 10/10 | 5/10 |
| **Funkcjonalność** | 🥇 10/10 | 7/10 | 8/10 | 10/10 |
| **Prywatność** | 🥇 10/10 | 9/10 | 7/10 | 9/10 |
| **Koszt** | 🥇 10/10 | 8/10 | 8/10 | 6/10 |
| **Gateway/Routing** | 🥈 8/10 | 0/10 | 0/10 | 10/10 |
| **Parental Control** | 🥈 9/10 | 5/10 | 9/10 | 9/10 |
| **Dokumentacja PL** | 🥇 10/10 | 0/10 | 3/10 | 0/10 |
| **ŚREDNIA** | **🥇 9.4/10** | 7.2/10 | 8.0/10 | 7.6/10 |

---

## 🏅 WERDYKT KOŃCOWY

### **Citadel v3.2 (z Gateway Mode):**

**🥇 NAJLEPSZA dla:**
- Privacy-conscious użytkowników domowych
- Rodzin z dziećmi (parental control)
- Małych firm
- Użytkowników którzy chcą pełnej kontroli
- Polskich użytkowników (dokumentacja PL)

**Przewagi:**
1. **Najlepsze bezpieczeństwo DNS** (DNSCrypt + leak prevention)
2. **Najlepsza prywatność** (zero telemetry, local-first)
3. **Najbardziej modułowa** (łatwy rozwój)
4. **Najtańsza** (stary PC za 150 zł)
5. **Jedyna z pełną dokumentacją PL**

**Wady:**
1. Brak Web UI (tylko TUI/CLI) - dla niektórych minus
2. Wymaga podstawowej znajomości CLI
3. Nie jest pełnym firewallem (jak pfSense)

---

## 💡 UNIQUE SELLING POINTS (USP)

**Co Citadel robi LEPIEJ niż konkurencja:**

1. **Privacy-first** - zero telemetry, local-first, supply-chain verification
2. **Modułowa** - łatwo dodawać nowe funkcje
3. **Multi-blocklist** - 6 profili (light/balanced/aggressive/privacy/polish/custom)
4. **Polish-first** - pełna dokumentacja PL, wsparcie społeczności
5. **Budget-friendly** - działa na starym PC za 150 zł
6. **DNS Security** - jedyna z DNSCrypt + strict NFTables leak prevention
7. **Interactive installer** - wizard z checklistą
8. **Desktop notifications** - alerty systemowe

---

## 🎯 PODSUMOWANIE

**Citadel v3.2 (z Gateway Mode) będzie:**

**Najlepsza dla prywatności i bezpieczeństwa DNS** 🥇  
**Równa z Pi-hole/AdGuard w adblock** 🥈  
**Lepsza niż Pi-hole w funkcjonalności** 🥇  
**Tańsza niż wszystkie** 🥇  
**Jedyna z pełną dokumentacją PL** 🥇

**Ocena końcowa: 9.4/10** 🏆

---

**Plik utworzony:** 2026-01-30  
**Dla:** Decyzja o dalszym rozwoju projektu
