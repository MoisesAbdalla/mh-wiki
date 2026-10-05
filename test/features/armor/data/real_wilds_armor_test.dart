import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/armor/data/armor_dataset_dto.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';

/// 010 T008: the shipped Wilds armor.
void main() {
  late ArmorCatalog catalog;

  setUpAll(() {
    final json = jsonDecode(
      File('assets/data/wilds/armor.json').readAsStringSync(),
    ) as Map<String, Object?>;
    catalog = readArmorDataset(json, expectedGame: Game.wilds);
  });

  test('counts and pt-BR names (SC-001)', () {
    expect(catalog.sets, hasLength(183));
    expect(catalog.pieces, hasLength(714));
    expect(catalog.skills, hasLength(179));
    expect(catalog.decorations, hasLength(361));
    expect(catalog.talismans, hasLength(64));
    final pt = catalog.pieces.where((p) => p.name.ptBr != null).length;
    expect(pt / catalog.pieces.length, greaterThanOrEqualTo(0.99));
  });

  test('Arkveld α: rarity 8, set bonus 2/4 and group bonus 3', () {
    final set = catalog.sets.firstWhere((s) => s.name.en == 'Arkveld α');
    expect(set.pieces, hasLength(5));
    expect(set.pieces.every((p) => p.rarity == 8), isTrue);
    expect(set.rank, Rank.high);
    final bonus = set.bonus!;
    expect(catalog.skill(bonus.skillId)!.kind, SkillKind.set);
    expect(bonus.steps.map((s) => s.pieces), [2, 4]);
    expect(bonus.steps.first.name.ptBr, 'Regeneração Veloz I');
    final group = set.groupBonus!;
    expect(catalog.skill(group.skillId)!.kind, SkillKind.group);
    expect(group.steps.single.pieces, 3);
    expect(group.steps.single.name.ptBr, 'Fortificar');
  });

  test('decorations: kind, icon, two skills', () {
    final weapon = catalog.decorations.where(
      (d) => d.kind == DecorationKind.weapon,
    );
    final armor = catalog.decorations.where(
      (d) => d.kind == DecorationKind.armor,
    );
    expect(weapon, isNotEmpty);
    expect(armor, isNotEmpty);
    final two = catalog.decorations.firstWhere(
      (d) => d.name.ptBr == 'Joia Stat. Crít./Artesanato 3',
    );
    expect(two.skills, hasLength(2));
    for (final d in catalog.decorations) {
      expect(File(d.iconAsset!).existsSync(), isTrue, reason: d.id);
    }
  });

  test('talismans have ranks in order', () {
    final t = catalog.talismans.firstWhere(
      (t) => t.ranks.first.name.ptBr == 'Amuleto da Fartura I',
    );
    expect(t.ranks.map((r) => r.level), [1, 2, 3]);
    expect(t.ranks.last.skills.single.level, 3);
  });

  test('every piece shows a Wilds image or its part icon (SC-003)', () {
    final images = catalog.pieces
        .where((p) => p.imageAsset != null && File(p.imageAsset!).existsSync())
        .length;
    // The rest fall back to assets/images/wilds/icons/<part>-<rarity>.webp.
    expect(images / catalog.pieces.length, greaterThan(0.8));
    for (final p in catalog.pieces) {
      final icon = 'assets/images/wilds/icons/${p.part.name}-${p.rarity}.webp';
      expect(File(icon).existsSync(), isTrue, reason: icon);
    }
  });
}
