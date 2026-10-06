import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/armor/data/armor_dataset_dto.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';

/// 011 T007: the shipped World: Iceborne armor.
void main() {
  late ArmorCatalog catalog;

  setUpAll(() {
    final json = jsonDecode(
      File('assets/data/world_iceborne/armor.json').readAsStringSync(),
    ) as Map<String, Object?>;
    catalog = readArmorDataset(json, expectedGame: Game.worldIceborne);
  });

  test('counts, ranks and pt-BR names (SC-001)', () {
    expect(catalog.sets, hasLength(360));
    expect(catalog.pieces, hasLength(1638));
    expect(catalog.decorations, hasLength(405));
    expect(catalog.talismans, hasLength(109));
    expect(catalog.sets.map((s) => s.rank).toSet(), Rank.values.toSet());
    final named = [
      ...catalog.pieces.map((p) => p.name),
      ...catalog.decorations.map((d) => d.name),
      ...catalog.skills.map((s) => s.name),
      ...catalog.talismans.expand((t) => t.ranks).map((r) => r.name),
    ];
    final pt = named.where((n) => n.ptBr != null).length;
    expect(pt / named.length, greaterThanOrEqualTo(0.97));
  });

  test('Fatalis α+ (the US2 independent test)', () {
    final set = catalog.sets.firstWhere((s) => s.name.en == 'Fatalis α+');
    expect(set.pieces, hasLength(5));
    expect(set.pieces.every((p) => p.rarity == 12), isTrue);
    expect(set.rank, Rank.master);
    expect(set.pieces.first.name.ptBr, 'Cabeça de Dragão α+');
    expect(set.pieces.first.slots, [3, 2, 2]);
    expect(set.pieces.first.maxDefense, greaterThan(set.pieces.first.defense));
    final bonus = set.bonus!;
    expect(catalog.skill(bonus.skillId)!.name.ptBr, 'Lenda de Fatalis');
    expect(bonus.steps.map((s) => s.pieces), [2, 4]);
    expect(
      bonus.steps.first.description.ptBr,
      'Remove o limite de nível dos segredos de habilidade.',
    );
  });

  test('skills: set and secret kinds', () {
    final kinds = catalog.skills.map((s) => s.kind).toSet();
    expect(
      kinds,
      containsAll([SkillKind.armor, SkillKind.set, SkillKind.secret]),
    );
    expect(
      catalog.skills.firstWhere((s) => s.name.en == 'Weakness Exploit').kind,
      SkillKind.armor,
    );
  });

  test('level 4 decorations with two skills, and World icons', () {
    final d = catalog.decorations.firstWhere(
      (d) => d.name.en == 'Fortitude/Attack Jewel 4',
    );
    expect(d.slotLevel, 4);
    expect(d.skills, hasLength(2));
    expect(d.name.ptBr, 'Joia Ataque/Fortitude 4');
    for (final d in catalog.decorations) {
      expect(File(d.iconAsset!).existsSync(), isTrue, reason: d.id);
    }
  });

  test('talismans I–V', () {
    final t = catalog.talismans.firstWhere(
      (t) => t.ranks.first.name.en == 'Attack Charm I',
    );
    expect(t.ranks.map((r) => r.level), [1, 2, 3, 4, 5]);
    expect(t.ranks.last.name.ptBr, 'Amuleto de Ataque V');
    expect(t.ranks.last.skills.single.level, 5);
  });

  test('every piece has a World part icon (SC-003)', () {
    for (final p in catalog.pieces) {
      final icon = 'assets/images/world/icons/${p.part.name}-${p.rarity}.webp';
      expect(File(icon).existsSync(), isTrue, reason: icon);
    }
  });
}
