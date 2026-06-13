#!/usr/bin/env bash
# agent-perf-tracker — PostToolUse hook: Task tool tamamlandığında agent kalite kaydeder.
# YENİ v4: Özellik 2 — cost-router adaptif routing'i besler.
# docs/agent-perf-history.json'a {agent, task_type, duration_ms, exit_code, ts} yazar.
# Bu dosya cost-router.md'nin "Adaptif Routing" özelliği tarafından okunur.

set -euo pipefail

INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)

# Sadece Task tool çağrıları
[[ "$TOOL" != "Task" ]] && exit 0

PERF_FILE="docs/agent-perf-history.json"
mkdir -p docs 2>/dev/null || true

# Task bilgileri
TASK_DESC=$(echo "$INPUT" | jq -r '.tool_input.description // "unknown"' 2>/dev/null || echo "unknown")
TASK_DURATION=$(echo "$INPUT" | jq -r '.duration_ms // 0' 2>/dev/null || echo 0)
TASK_EXIT=$(echo "$INPUT" | jq -r '.exit_code // 0' 2>/dev/null || echo 0)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Agent adını description'dan çıkarmaya çalış
AGENT_NAME="unknown"
for known in qa-expert security-auditor vault-curator release-manager \
             codebase-orchestrator ui-craftsman refactoring-specialist \
             performance-engineer cost-router rag-architect mcp-builder \
             vault-guardian codex-delegate gemini-delegate i18n-translator; do
  if echo "$TASK_DESC" | grep -qi "$known"; then
    AGENT_NAME="$known"
    break
  fi
done

# Mevcut dosyayı oku (yoksa sıfırla)
PERF_DATA="{}"
[[ -f "$PERF_FILE" ]] && PERF_DATA=$(cat "$PERF_FILE" 2>/dev/null || echo "{}")

# jq ile güncelle (agent anahtarı yoksa oluştur)
NEW_PERF=$(echo "$PERF_DATA" | jq \
  --arg agent "$AGENT_NAME" \
  --arg ts "$TS" \
  --argjson dur "${TASK_DURATION}" \
  --argjson exit_code "${TASK_EXIT}" \
  '
    .[$agent] //= {"total_tasks": 0, "success_count": 0, "avg_duration_ms": 0, "history": []}
    | .[$agent].total_tasks += 1
    | .[$agent].success_count += (if $exit_code == 0 then 1 else 0 end)
    | .[$agent].history = (
        [{"ts": $ts, "duration_ms": $dur, "exit_code": $exit_code}]
        + .[$agent].history[0:49]
      )
    | .[$agent].avg_duration_ms = (
        (.[$agent].history | map(.duration_ms) | add) / (.[$agent].history | length)
        | floor
      )
  ' 2>/dev/null || echo "$PERF_DATA")

echo "$NEW_PERF" > "$PERF_FILE" 2>/dev/null || true

exit 0
