---
theme: default
layout: two-cols
---

# Mecanismo de interrupciones

<div class="text-xs text-gray-300 mb-2">
Flujo de transición entre espacio de usuario y núcleo.
</div>

<div class="space-y-1.5 text-xs">
  <div class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
    <strong class="text-amber-400">1. int 0x80:</strong> Excepción por software controlada.
  </div>
  <div class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
    <strong class="text-cyan-400">2. Conmutación:</strong> CPU conmuta a Anillo 0.
  </div>
  <div class="p-2 bg-gray-900/60 border border-gray-800 rounded-lg">
    <strong class="text-emerald-400">3. iret:</strong> Núcleo retorna a Anillo 3.
  </div>
</div>

::right::

```mermaid
sequenceDiagram
    autonumber
    actor U as Usuario (Ring 3)
    actor K as Núcleo (Ring 0)
    U->>K: int 0x80 (EAX, EBX, ECX, EDX)
    Note over K: IDT[0x80] -> sys_call_table[EAX]
    Note over K: Ejecuta servicio
    K-->>U: iret (Retorno en EAX)
```
