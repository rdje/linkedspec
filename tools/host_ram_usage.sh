#!/usr/bin/env bash
# Read-only host availability estimate shared by RAM guard and canonical CI.
# Darwin available = free + inactive + speculative pages from one vm_stat call.
# The integer used percentage rounds upward. This is not a pressure/trend monitor.

linkedspec_host_ram_used_pct() {
  local platform total pressure snapshot
  platform=$(uname -s) || return 1
  case "$platform" in
    Darwin)
      if ! total=$(sysctl -n hw.memsize 2>/dev/null) || [[ ! "$total" =~ ^[1-9][0-9]*$ ]]; then
        pressure=$(LC_ALL=C memory_pressure -Q) || {
          printf 'host_ram_usage: host capacity unavailable\n' >&2
          return 1
        }
        total=$(printf '%s\n' "$pressure" | LC_ALL=C awk '
          /^The system has [0-9]+ \([0-9]+ pages with a page size of [0-9]+\)\.$/ { count++; total=$4 }
          END { if (count != 1 || total <= 0) exit 1; printf "%.0f\n", total }
        ') || {
          printf 'host_ram_usage: invalid memory_pressure host capacity\n' >&2
          return 1
        }
      fi
      snapshot=$(LC_ALL=C vm_stat) || {
        printf 'host_ram_usage: vm_stat snapshot unavailable\n' >&2
        return 1
      }
      printf '%s\n' "$snapshot" | LC_ALL=C awk -v total="$total" '
        /^Mach Virtual Memory Statistics: \(page size of [0-9]+ bytes\)$/ { headers++; page_size=$8 }
        $1 == "Pages" && ($2 == "free:" || $2 == "inactive:" || $2 == "speculative:") {
          key=$2; seen[key]++
          if (NF != 3 || $3 !~ /^[0-9]+[.]$/) invalid=1
          value=$3; sub(/[.]$/, "", value); pages[key]=value
        }
        END {
          available=(pages["free:"] + pages["inactive:"] + pages["speculative:"]) * page_size
          if (headers != 1 || page_size <= 0 || total <= 0 || invalid ||
              seen["free:"] != 1 || seen["inactive:"] != 1 || seen["speculative:"] != 1 ||
              available < 0 || available > total) {
            print "host_ram_usage: invalid vm_stat capacity/snapshot" > "/dev/stderr"
            exit 1
          }
          printf "%d\n", 100 - int(available * 100 / total)
        }
      '
      ;;
    Linux)
      snapshot=$(cat /proc/meminfo) || {
        printf 'host_ram_usage: /proc/meminfo unavailable\n' >&2
        return 1
      }
      printf '%s\n' "$snapshot" | LC_ALL=C awk '
        $1 == "MemTotal:" || $1 == "MemAvailable:" {
          seen[$1]++
          if (NF != 3 || $2 !~ /^[0-9]+$/ || $3 != "kB") invalid=1
          value[$1]=$2
        }
        END {
          total=value["MemTotal:"]; available=value["MemAvailable:"]
          if (seen["MemTotal:"] != 1 || seen["MemAvailable:"] != 1 || invalid ||
              total <= 0 || available < 0 || available > total) {
            print "host_ram_usage: invalid /proc/meminfo capacity/snapshot" > "/dev/stderr"
            exit 1
          }
          printf "%d\n", 100 - int(available * 100 / total)
        }
      '
      ;;
    *)
      printf 'host_ram_usage: unsupported host platform: %s\n' "$platform" >&2
      return 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  linkedspec_host_ram_used_pct
fi
