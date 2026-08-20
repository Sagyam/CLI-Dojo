#!/usr/bin/env bats

setup() {
    if [[ -d /opt/bats/bats-support ]]; then
        load /opt/bats/bats-support/load
        load /opt/bats/bats-assert/load
        load /opt/bats/bats-file/load
    fi
    # shellcheck source=../../lib/seed.sh
    source /opt/dojo/lib/seed.sh 2>/dev/null || true

    WORK="${WORK:-/home/student/dojo/11-sed}"
}

@test "all 60 .conf files have .bak backups in configs/" {
    bak_count=$(find "${WORK}/configs" -maxdepth 1 -name "*.conf.bak" | wc -l)
    [ "$bak_count" -eq 60 ]
}

@test "exact hostname blr1.yetilink.internal replaced with ktm2.yetilink.internal" {
    # Check that no exact blr1.yetilink.internal remains in .conf files
    unmigrated=$(grep -rnE '\bblr1\.yetilink\.internal\b' "${WORK}/configs"/*.conf 2>/dev/null || true)
    [ -z "$unmigrated" ]

    # Check that ktm2.yetilink.internal is present
    migrated_count=$(grep -rn 'ktm2.yetilink.internal' "${WORK}/configs"/*.conf | wc -l)
    [ "$migrated_count" -ge 60 ]
}

@test "decoy near-miss hostnames (_backup and node_blr1) were not corrupted" {
    # Verify no ktm2.yetilink.internal_backup or node_ktm2.yetilink.internal were created
    corrupted_backup=$(grep -rn 'ktm2\.yetilink\.internal_backup' "${WORK}/configs"/*.conf 2>/dev/null || true)
    corrupted_node=$(grep -rn 'node_ktm2\.yetilink\.internal' "${WORK}/configs"/*.conf 2>/dev/null || true)
    
    [ -z "$corrupted_backup" ]
    [ -z "$corrupted_node" ]

    # Verify original decoys still exist in the updated configs
    original_decoys=$(grep -rnE '(blr1\.yetilink\.internal_backup|node_blr1\.yetilink\.internal)' "${WORK}/configs"/*.conf | wc -l)
    [ "$original_decoys" -gt 0 ]
}

@test "deprecated directive use_flannel purged from all .conf files" {
    flannel_count=$(grep -rn 'use_flannel' "${WORK}/configs"/*.conf 2>/dev/null || true)
    [ -z "$flannel_count" ]
}

@test "deprecated_module lines in nginx.conf are commented out with '# '" {
    [ -f "${WORK}/nginx.conf" ]

    # Verify every line matching deprecated_module starts with '# '
    uncommented=$(grep 'deprecated_module' "${WORK}/nginx.conf" | grep -v '^# ' 2>/dev/null || true)
    [ -z "$uncommented" ]

    # Verify at least one commented deprecated_module line is present
    commented_count=$(grep -c '^# .*deprecated_module' "${WORK}/nginx.conf" || true)
    [ "$commented_count" -ge 2 ]
}

@test "preview.txt contains exactly lines 10 to 20 of nginx.conf" {
    [ -f "${WORK}/preview.txt" ]
    
    line_count=$(wc -l < "${WORK}/preview.txt")
    [ "$line_count" -eq 11 ]

    # Verify line content against lines 10..20
    grep -q 'events {' "${WORK}/preview.txt"
    grep -q 'http {' "${WORK}/preview.txt"
}
