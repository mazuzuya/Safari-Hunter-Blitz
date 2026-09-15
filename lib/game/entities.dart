import 'dart:ui' as ui;
import 'data.dart';

class Entity {
  int id;
  Animal spec;
  double x;
  double baseY;
  double y;
  int direction;
  double speedVariance;
  double phase;
  double frameTime;
  bool rare;
  double visualScale;
  double opacity;
  bool decoy;
  bool guardian;
  bool totem;
  String? totemType;
  String? totemLabel;
  String? totemRisk;
  bool formationLeader;
  String behavior;
  int armorHits;
  bool submerged;
  bool wasSubmerged;
  double nextFeint;
  bool elite;
  int? formationId;
  ui.Rect? bounds;
  double renderSize = 0;

  Entity({
    required this.id,
    required this.spec,
    required this.x,
    required this.baseY,
    required this.y,
    required this.direction,
    required this.speedVariance,
    required this.phase,
    required this.frameTime,
    required this.rare,
    required this.visualScale,
    required this.opacity,
    required this.decoy,
    required this.guardian,
    required this.totem,
    this.totemType,
    this.totemLabel,
    this.totemRisk,
    required this.formationLeader,
    required this.behavior,
    required this.armorHits,
    required this.submerged,
    required this.wasSubmerged,
    required this.nextFeint,
    required this.elite,
    this.formationId,
  });
}

class Effect {
  final String type;
  final double x;
  final double y;
  double age;
  final String label;
  final bool negative;
  final double size;
  Effect(this.type, this.x, this.y, this.age, this.label, this.negative, this.size);
}

class Mutator {
  final String type;
  final String name;
  Mutator(this.type, this.name);
}
