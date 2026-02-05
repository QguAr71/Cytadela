# TODO Integracja Prometheus + Grafana

## Przegląd

Ten dokument śledzi implementację metryk Prometheus i dashboard Grafana dla Cytadela.

## Aktualny Status

✅ **Endpoint Prometheus CoreDNS** - `http://127.0.0.1:9153/metrics`
✅ **Podstawowe zbieranie metryk** - Trafienia cache, czasy odpowiedzi, liczba zapytań
✅ **Podgląd dashboard** - Terminalowy `citadel-top`

## Dostępne Metryki Prometheus

### Metryki CoreDNS (Port 9153)

| Metryka | Opis |
|---------|------|
| `coredns_build_info` | Informacje o wersji CoreDNS |
| `coredns_cache_entries` | Liczba wpisów w cache |
| `coredns_cache_hits_total` | Łączna liczba trafień cache |
| `coredns_cache_misses_total` | Łączna liczba chybień cache |
| `coredns_dns_request_count_total` | Łączna liczba zapytań DNS |
| `coredns_dns_request_duration_seconds` | Histogram opóźnienia zapytań |

### Niestandardowe Metryki Cytadela (Planowane)

| Metryka | Opis | Status |
|---------|------|--------|
| `cytadela_blocked_queries_total` | Zablokowane przez adblock | 🔄 TODO |
| `cytadela_upstream_latency_ms` | Opóźnienie DNSCrypt | 🔄 TODO |
| `cytadela_firewall_blocks_total` | Zablokowane przez firewall | 🔄 TODO |
| `cytadela_active_connections` | Aktywne połączenia DNS | 🔄 TODO |

## Dashboard Grafana

### Istniejące
- `docs/grafana-dashboard.json` - Podstawowy szablon dashboard

### Planowane Widgety
- [ ] Tempo zapytań DNS (QPS)
- [ ] Współczynnik trafień cache
- [ ] Procent zablokowanych zapytań
- [ ] Opóźnienie upstream
- [ ] Top zablokowanych domen
- [ ] Mapa geograficzna zapytań

## Kroki Implementacji

### Faza 1: Serwer Prometheus
```bash
# Zainstaluj Prometheus
sudo pacman -S prometheus

# Skonfiguruj zbieranie
cat > /etc/prometheus/prometheus.yml << 'EOF'
scrape_configs:
  - job_name: 'coredns'
    static_configs:
      - targets: ['localhost:9153']
EOF

# Włącz usługę
sudo systemctl enable --now prometheus
```

### Faza 2: Grafana
```bash
# Zainstaluj Grafana
sudo pacman -S grafana

# Importuj dashboard
sudo cp docs/grafana-dashboard.json /var/lib/grafana/dashboards/

# Włącz usługę
sudo systemctl enable --now grafana
```

### Faza 3: Niestandardowy Exporter (Opcjonalny)
Utwórz niestandardowy exporter dla metryk specyficznych dla Cytadela poza CoreDNS.

## Dostęp

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **Metryki CoreDNS**: http://localhost:9153/metrics

## Polecenia

```bash
# Wyświetl metryki ręcznie
curl -s http://127.0.0.1:9153/metrics | grep "coredns_"

# Sprawdź cele Prometheus
sudo ./citadel.sh prometheus-status

# Wyświetl w terminalu
curl -s http://127.0.0.1:9153/metrics | grep "^coredns_" | head -10
```

## Zasoby

- [Dokumentacja Prometheus](https://prometheus.io/docs/)
- [Dokumentacja Grafana](https://grafana.com/docs/)
- [Metryki CoreDNS](https://coredns.io/plugins/metrics/)
