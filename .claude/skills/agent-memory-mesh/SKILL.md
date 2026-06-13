---
name: agent-memory-mesh
description: "Agent'lar arası paylaşımlı hafıza koordinasyonu. vault-curator + prompt-enricher gibi birden fazla agent'ın aynı öğeye eş zamanlı yazmasını önler, Yjs CRDT benzeri bir merge protokolü sağlar. [YENİ v2]"
tools: Read, Write, Bash
model: haiku
---

# Agent Memory Mesh Skill

Birden fazla agent'ın eş zamanlı vault yazımını koordine eder. `@modelcontextprotocol/server-memory` MCP üzerine inşa edilir.

## Ne zaman kullanılır

- Paralel batch-enrich sırasında aynı vault'a birden fazla agent yazıyor
- vault-curator + prompt-enricher eş zamanlı çalışıyor
- orchestrator birden fazla agent'a aynı vault'u hedef gösterdi

## Kilit (Lock) Protokolü

```js
// MCP memory server üzerinden distributed lock
const LOCK_KEY = `vault-lock:${vaultName}`;
const LOCK_TTL = 30_000; // 30 saniye

async function acquireLock(vaultName, agentId) {
  const existing = await memory.get(LOCK_KEY);
  if (existing && Date.now() - existing.ts < LOCK_TTL) {
    return { acquired: false, holder: existing.agent };
  }
  await memory.set(LOCK_KEY, { agent: agentId, ts: Date.now() });
  return { acquired: true };
}

async function releaseLock(vaultName, agentId) {
  const lock = await memory.get(LOCK_KEY);
  if (lock?.agent === agentId) {
    await memory.delete(LOCK_KEY);
  }
}
```

## Eş zamanlı yazma çakışması (Merge Protokolü)

İki agent aynı öğeyi güncellemeye çalışırsa:

1. **İlk gelen kazanır** — lock alan agent yazar
2. **İkincisi bekler** (500ms retry, max 5 deneme)
3. **Lock TTL aşılırsa** — eski lock'u zorla al, kullanıcıya bildir
4. **Çakışma raporu** — `data/audit-log.ndjson`'a conflict kaydı düşer

```json
{"ts":"...","event":"lock_conflict","vault":"PromptVault","agents":["vault-curator","prompt-enricher"],"resolution":"first_wins"}
```

## Paylaşımlı durum

MCP memory'de tutulan ortak state:
- `vault-lock:{name}` → Aktif kilit (agent + timestamp)
- `enrichment-queue:{name}` → Hangi item ID'ler işleniyor
- `agent-activity:{session}` → Hangi agent'lar aktif (heartbeat)

## Kullanım (orchestrator tarafından)

```
vault-curator'ı spawn etmeden önce:
1. agent-memory-mesh skill'ini çağır
2. Lock al: acquireLock("PromptVault", "vault-curator")
3. vault-curator → işini yap
4. Lock bırak: releaseLock("PromptVault", "vault-curator")

Paralel batch'te:
- Her agent farklı item aralığı alır (shard by index)
- Vault seviyesinde değil, item ID seviyesinde lock
```

## Çıktı

```
🔗 Agent Memory Mesh
   vault: PromptVault
   lock: acquired by vault-curator (session: abc123)
   queue: 45 items pending enrichment
   active agents: vault-curator, prompt-enricher (shard B)
   conflicts: 0
```
