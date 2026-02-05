# Moduł Benchmark

## Przegląd

Moduł `benchmark.sh` udostępnia testowanie wydajności DNS używając narzędzia `dnsperf`.

## Lokalizacja

```
modules/benchmark.sh
```

## Wymagania

```bash
# Zainstaluj dnsperf
sudo pacman -S dnsperf
```

## Użycie

```bash
# Uruchom benchmark
sudo ./citadel.sh benchmark

# Z własnymi parametrami
sudo ./citadel.sh benchmark --queries 10000 --clients 50
```

## Parametry Testu

| Parametr | Domyślny | Opis |
|----------|----------|------|
| Queries | 10000 | Całkowita liczba zapytań |
| Clients | 50 | Równoległe klienty |
| Duration | 60s | Czas trwania testu |
| Target | 127.0.0.1:53 | Serwer DNS do testowania |

## Metryki Wyników

| Metryka | Opis |
|---------|------|
| QPS | Zapytania na sekundę |
| Latency (avg) | Średni czas odpowiedzi |
| Latency (max) | Maksymalny czas odpowiedzi |
| Success rate | Procent udanych zapytań |
| Cache hit rate | Efektywność cache |

## Przykładowe Wyniki

```
DNS Performance Benchmark
=========================
Duration: 60 seconds
Queries: 10,000
Clients: 50

Results:
- QPS: 89,127
- Avg Latency: 12ms
- Max Latency: 45ms
- Success Rate: 100%
- Cache Hit Rate: 94.2%
```

## Interpretacja

| QPS | Ocena |
|-----|-------|
| >50,000 | Doskonała |
| 20,000-50,000 | Dobra |
| 10,000-20,000 | Akceptowalna |
| <10,000 | Wymaga optymalizacji |

## Rozwiązywanie Problemów

**dnsperf nie znaleziony:**
```bash
sudo pacman -S dnsperf
```

**Wysokie opóźnienie:**
- Sprawdź obciążenie CPU: `htop`
- Zweryfikuj ustawienia cache: `cat /etc/coredns/Corefile`
- Sprawdź upstream DNS: `sudo ./citadel.sh diagnostics`

## Szczegóły Implementacji

Benchmark:
1. Generuje plik testowych zapytań z domenami
2. Uruchamia dnsperf przeciwko lokalnemu CoreDNS
3. Parsuje wyniki i oblicza statystyki
4. Generuje czytelny dla człowieka raport
