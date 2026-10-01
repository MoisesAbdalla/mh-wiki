import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';

/// Element or status a weapon deals.
enum SpecialKind {
  fire,
  water,
  thunder,
  ice,
  dragon,
  poison,
  sleep,
  paralysis,
  blast;

  /// The matching element, or `null` for statuses.
  ElementType? get element => switch (this) {
    fire => ElementType.fire,
    water => ElementType.water,
    thunder => ElementType.thunder,
    ice => ElementType.ice,
    dragon => ElementType.dragon,
    _ => null,
  };
}
