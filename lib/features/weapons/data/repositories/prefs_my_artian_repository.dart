import 'dart:convert';

import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's saved Artian, kept on the device (010 FR-012).
class PrefsMyArtianRepository implements MyArtianRepository {
  PrefsMyArtianRepository(this._prefs);

  static const key = 'weapons.wilds.myArtians.v1';

  final SharedPreferences _prefs;

  @override
  Future<List<MyArtian>> load() async {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List<Object?>)
          () {
            final m = e! as Map<String, Object?>;
            final b = m['build']! as Map<String, Object?>;
            final boosts = (b['boosts'] as Map<String, Object?>?) ?? const {};
            return MyArtian(
              id: m['id']! as String,
              name: m['name']! as String,
              build: ArtianBuild(
                type: b['type']! as String,
                rarity: b['rarity']! as int,
                element: b['element'] as String?,
                elementParts: b['elementParts']! as int,
                attackParts: b['attackParts']! as int,
                boosts: {
                  for (final e in boosts.entries)
                    ArtianBoost.values.byName(e.key): e.value! as int,
                },
              ),
            );
          }(),
      ];
    } on Object {
      // A corrupt value must not break Armas: start empty.
      return const [];
    }
  }

  @override
  Future<bool> store(List<MyArtian> artians) => _prefs.setString(
    key,
    jsonEncode([
      for (final a in artians)
        {
          'id': a.id,
          'name': a.name,
          'build': {
            'type': a.build.type,
            'rarity': a.build.rarity,
            'element': ?a.build.element,
            'elementParts': a.build.elementParts,
            'attackParts': a.build.attackParts,
            'boosts': {
              for (final e in a.build.boosts.entries)
                if (e.value > 0) e.key.name: e.value,
            },
          },
        },
    ]),
  );
}
