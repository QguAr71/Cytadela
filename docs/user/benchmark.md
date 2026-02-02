# Benchmark Module

## Overview

The `benchmark.sh` module provides DNS performance testing using `dnsperf` tool.

## Location

```
modules/benchmark.sh
```

## Requirements

```bash
# Install dnsperf
sudo pacman -S dnsperf
```

## Usage

```bash
# Run benchmark
sudo ./citadel.sh benchmark

# With custom parameters
sudo ./citadel.sh benchmark --queries 10000 --clients 50
```

## Test Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Queries | 10000 | Total number of queries |
| Clients | 50 | Concurrent clients |
| Duration | 60s | Test duration |
| Target | 127.0.0.1:53 | DNS server to test |

## Output Metrics

| Metric | Description |
|--------|-------------|
| QPS | Queries per second |
| Latency (avg) | Average response time |
| Latency (max) | Maximum response time |
| Success rate | Percentage of successful queries |
| Cache hit rate | Cache effectiveness |

## Example Results

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

## Interpretation

| QPS | Rating |
|-----|--------|
| >50,000 | Excellent |
| 20,000-50,000 | Good |
| 10,000-20,000 | Acceptable |
| <10,000 | Needs optimization |

## Troubleshooting

**dnsperf not found:**
```bash
sudo pacman -S dnsperf
```

**High latency:**
- Check CPU load: `htop`
- Verify cache settings: `cat /etc/coredns/Corefile`
- Check upstream DNS: `sudo ./citadel.sh diagnostics`

## Implementation Details

The benchmark:
1. Generates test query file with domains
2. Runs dnsperf against local CoreDNS
3. Parses results and calculates statistics
4. Generates human-readable report
