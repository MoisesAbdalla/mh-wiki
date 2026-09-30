# Contract: Hunting info on the monster detail

Two new `HunterPanel` sections, between "Fraquezas elementais" and "Habitat/Partes".

## "HP"

- One row per rank present: rank name · solo HP ("20.800" or "a partir de 9.000").
- Party row per rank: "Grupo (aprox.)" with 2 / 3 / 4 values or ranges ("≈ 33.000 – 39.000"),
  and a small "Fonte: <name>" line; Rise shows "Grupo: Desconhecido".
- Numbers in pt-BR format (thousands with ".").
- No hp data at all → "HP desconhecido".

## "Itens de caça"

- Line "Visão: Enxerga" or "Visão: Desconhecido".
- One row per item of the game: item name (per name-language setting) · status badge:
  "Afeta" (gold), "Não afeta" (muted), "Afeta com condição" (gold outline) + detail text,
  "Desconhecido" (muted italic).
- Details (duration, flee chance, condition) under the item name.
- Semantics: each row reads "<item>: <status>. <detail>".

Accessibility and visual rules of feature 002 apply (contrast, 48 dp, 200% text).
