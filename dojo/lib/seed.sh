#!/usr/bin/env bash
# YetiLink CLI Dojo — Seed Library (seed.sh)
# Deterministic PRNG helpers using a standard Linear Congruential Generator (LCG)
# Completely independent of bash internal $RANDOM

# Built-in wordlist (YetiLink themes & tech terms)
SEEDED_WORDS=(
    "momo" "chiya" "dalbhat" "himal" "pokhara" "namaste" "everest" "annapurna"
    "mustang" "patan" "bhaktapur" "thamel" "lhotse" "makalu" "langtang" "chitwan"
    "suresh" "anita" "prakash" "yetilink" "kathmandu" "bagmati" "swayambhu" "durbar"
    "router" "gateway" "daemon" "kernel" "packet" "socket" "buffer" "firewall"
    "switch" "subnet" "interface" "dns" "dhcp" "uplink" "bgp" "ospf" "vlan"
)

_SEED_STATE=42

# Initialize seed
seed_init() {
    local requested_seed="${1:-}"
    if [[ -n "$requested_seed" ]]; then
        SEED="$requested_seed"
    elif [[ -n "${SEED:-}" ]]; then
        :
    else
        SEED=42
    fi
    # Force positive 31-bit integer
    _SEED_STATE="$(( SEED & 0x7fffffff ))"
}

# LCG: a=1103515245, c=12345, m=2^31 (glibc standard)
_seed_next() {
    _SEED_STATE="$(( (_SEED_STATE * 1103515245 + 12345) & 0x7fffffff ))"
    echo "$_SEED_STATE"
}

# seeded_int MIN MAX
seeded_int() {
    local min="$1"
    local max="$2"
    if [[ "$min" -ge "$max" ]]; then
        echo "$min"
        return
    fi
    local range=$((max - min + 1))
    local rand
    rand=$(_seed_next)
    echo "$(( min + (rand % range) ))"
}

# seeded_pick item1 item2 ...
seeded_pick() {
    if [[ $# -eq 0 ]]; then
        return
    fi
    local items=("$@")
    local count=${#items[@]}
    local idx
    idx=$(seeded_int 0 $((count - 1)))
    echo "${items[idx]}"
}

# seeded_word
seeded_word() {
    seeded_pick "${SEEDED_WORDS[@]}"
}

# seeded_ip [prefix]
seeded_ip() {
    local prefix="${1:-10.10}"
    local b3
    local b4
    b3=$(seeded_int 1 254)
    b4=$(seeded_int 2 254)
    echo "${prefix}.${b3}.${b4}"
}

# seeded_hex [length]
seeded_hex() {
    local length="${1:-8}"
    local hex_chars="0123456789abcdef"
    local result=""
    for ((i = 0; i < length; i++)); do
        local idx
        idx=$(seeded_int 0 15)
        result="${result}${hex_chars:idx:1}"
    done
    echo "$result"
}

# seeded_shuffle items...
seeded_shuffle() {
    local items=("$@")
    local n=${#items[@]}
    for ((i = n - 1; i > 0; i--)); do
        local j
        j=$(seeded_int 0 "$i")
        local tmp="${items[i]}"
        items[i]="${items[j]}"
        items[j]="$tmp"
    done
    printf "%s\n" "${items[@]}"
}
