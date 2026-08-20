#!/usr/bin/env bash
echo "[HIDDEN_STDOUT] Standard output line 1"
echo "[HIDDEN_STDERR] Standard error warning 1" >&2
echo "[HIDDEN_STDOUT] Standard output line 2"
exit 3
