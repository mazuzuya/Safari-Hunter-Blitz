import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'data.dart';
import 'entities.dart';
import 'frame_data.dart';

const Map<String, List<double>> ZONE_BANDS = {
  'sky': [0.08, 0.32],
  'land': [0.32, 0.71],
  'water': [0.71, 1.0],
};

class RenderInput {
  final Stage stage;
  final List<Entity> entities;
  final List<Effect> effects;
  final Mutator? mutator;
  final double freezeTime;
  final bool paused;
  final bool challengeActive;
  final int radarLevel;
  final Map<String, int> targets;
  final double now;
  RenderInput({
    required this.stage,
    required this.entities,
    required this.effects,
    this.mutator,
    required this.freezeTime,
    required this.paused,
    required this.challengeActive,
    required this.radarLevel,
    required this.targets,
    required this.now,
  });
}

class Renderer {
  final Map<String, ui.Image> images;
  final Map<String, List<Frame>> animations;
  double width = 1;
  double height = 1;
  Renderer(this.images, this.animations);

  void resize(double w, double h) {
    width = w > 1 ? w : 1;
    height = h > 1 ? h : 1;
  }

  double get w => width;
  double get h => height;

  void _cover(ui.Canvas c, ui.Image image) {
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final scale = (width / iw) > (height / ih) ? width / iw : height / ih;
    final dw = iw * scale;
    final dh = ih * scale;
    final dx = (width - dw) / 2;
    final dy = (height - dh) / 2;
    c.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, iw, ih),
      ui.Rect.fromLTWH(dx, dy, dw, dh),
      ui.Paint(),
    );
  }

  void _text(
    ui.Canvas c,
    String text,
    double x,
    double y, {
    double size = 14,
    ui.Color color = const ui.Color(0xfffff4a5),
    bool bold = true,
    double stroke = 0,
    ui.Color strokeColor = const ui.Color(0xff3d2f13),
    ui.TextAlign align = ui.TextAlign.center,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
          fontFamily: 'Nunito',
        ),
      ),
      textAlign: align,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final offset = align == ui.TextAlign.center
        ? ui.Offset(x - tp.width / 2, y)
        : ui.Offset(x, y);
    if (stroke > 0) {
      final sp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size,
            foreground: ui.Paint()
              ..color = strokeColor
              ..strokeWidth = stroke
              ..style = ui.PaintingStyle.stroke,
            fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
            fontFamily: 'Nunito',
          ),
        ),
        textAlign: align,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      sp.paint(c, offset);
    }
    tp.paint(c, offset);
  }

  void _zoneTreatment(ui.Canvas c, List<String> activeZones) {
    ZONE_BANDS.forEach((zone, band) {
      final y = band[0] * height;
      final bh = (band[1] - band[0]) * height;
      if (!activeZones.contains(zone)) {
        c.drawRect(
          ui.Rect.fromLTWH(0, y, width, bh),
          ui.Paint()..color = const ui.Color(0x800d1e1c),
        );
      } else if (zone == 'water') {
        final g = ui.Gradient.linear(ui.Offset(0, y), ui.Offset(0, height), [
          const ui.Color(0x140fb4ce),
          const ui.Color(0x38003d6c),
        ]);
        c.drawRect(ui.Rect.fromLTWH(0, y, width, bh), ui.Paint()..shader = g);
      } else if (zone == 'land') {
        c.drawRect(
          ui.Rect.fromLTWH(0, y, width, bh),
          ui.Paint()..color = const ui.Color(0x12006a23),
        );
      }
    });
    final line = ui.Paint()
      ..color = const ui.Color(0x47ffffff)
      ..strokeWidth = 2;
    final path = ui.Path();
    for (double x = -20; x <= width + 20; x += 28) {
      final y = height * 0.71 + math.sin(x * 0.055) * 3;
      if (x == -20)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    c.drawPath(path, line);
    c.drawLine(
      ui.Offset(0, height * 0.32),
      ui.Offset(width, height * 0.32),
      ui.Paint()
        ..color = const ui.Color(0x4c3c5b26)
        ..strokeWidth = 2,
    );
  }

  void _halo(ui.Canvas c, Entity e, int radarLevel) {
    final strong = radarLevel > 0;
    final markerY = e.y - e.renderSize * 1.12;
    final markerSize =
        (e.renderSize * (0.42 + math.min(10, radarLevel) * 0.015))
            .clamp(18, 38)
            .toDouble();
    final markerAlpha = (0x99 + math.min(10, radarLevel) * 10)
        .clamp(0, 0xff)
        .toInt();
    _text(
      c,
      '!',
      e.x,
      markerY - 18,
      size: markerSize,
      color: strong
          ? ui.Color((markerAlpha << 24) | 0xffe146)
          : const ui.Color(0x99ef5a5a),
      stroke: 3,
      strokeColor: const ui.Color(0xd93d2f13),
    );
  }

  void _entity(ui.Canvas c, Entity e, RenderInput input) {
    // A previous frame must not leave an invisible entity tappable.
    e.bounds = null;
    final key = '${e.spec.sheet}:${e.spec.animation}';
    final frames = animations[key];
    if (frames == null || frames.isEmpty) return;
    final frameIndex =
        ((input.now + e.phase) / e.frameTime).floor() % frames.length;
    final frame = frames[frameIndex];
    double maxW = 1, maxH = 1;
    for (final f in frames) {
      if (f.w > maxW) maxW = f.w;
      if (f.h > maxH) maxH = f.h;
    }
    final sizeScale = (width / 390).clamp(0.78, 1.24);
    final targetHeight = e.spec.size * sizeScale * e.visualScale;
    final scale = targetHeight / maxH;
    e.renderSize = (frame.w > frame.h ? frame.w : frame.h) * scale;
    final img = images[e.spec.sheet];
    if (img == null) return;
    if (e.guardian) {
      final radius = targetHeight * 0.85;
      final cx = e.x;
      final cy = e.y - targetHeight * 0.5;
      final g = ui.Gradient.radial(
        ui.Offset(cx, cy),
        radius,
        [
          const ui.Color(0x42ffe25e),
          const ui.Color(0x1e47d399),
          const ui.Color(0x00ffe25e),
        ],
        [0.0, 0.55, 1.0],
      );
      c.save();
      c.drawRect(
        ui.Rect.fromLTWH(
          cx - radius,
          cy - radius * 1.5,
          radius * 2,
          radius * 2,
        ),
        ui.Paint()
          ..blendMode = ui.BlendMode.plus
          ..shader = g,
      );
      c.restore();
    }
    if (e.totem) {
      final radius = targetHeight * 0.82;
      final cx = e.x;
      final cy = e.y - targetHeight * 0.5;
      final g = ui.Gradient.radial(
        ui.Offset(cx, cy),
        radius,
        [
          const ui.Color(0x6bfff49b),
          const ui.Color(0x2e64efcf),
          const ui.Color(0x00ffffff),
        ],
        [0.0, 0.5, 1.0],
      );
      c.save();
      c.drawRect(
        ui.Rect.fromLTWH(
          cx - radius,
          cy - radius * 1.55,
          radius * 2,
          radius * 2,
        ),
        ui.Paint()
          ..blendMode = ui.BlendMode.plus
          ..shader = g,
      );
      c.restore();
    }
    final haloHidden =
        (input.stage.challenge == 'camouflage' && input.challengeActive) ||
        input.mutator?.type == 'moon';
    if (!e.decoy && !haloHidden && (input.targets[e.spec.id] ?? 0) > 0)
      _halo(c, e, input.radarLevel);
    if (e.rare) {
      final cx = e.x;
      final cy = e.y - targetHeight * 0.5;
      final g = ui.Gradient.radial(
        ui.Offset(cx, cy),
        targetHeight * 0.9,
        [
          const ui.Color(0x7fffffff),
          const ui.Color(0x3e6aeeff),
          const ui.Color(0x00ffd046),
        ],
        [0.0, 0.45, 1.0],
      );
      c.save();
      c.drawRect(
        ui.Rect.fromLTWH(
          cx - targetHeight,
          cy - targetHeight * 1.5,
          targetHeight * 2,
          targetHeight * 2,
        ),
        ui.Paint()
          ..blendMode = ui.BlendMode.plus
          ..shader = g,
      );
      c.restore();
    }
    final localX = (frame.x - frame.ax) * scale;
    final localY = (frame.y - frame.ay) * scale;
    final drawW = frame.w * scale;
    final drawH = frame.h * scale;
    final opacity = (e.opacity) * (e.decoy ? 0.76 : 1);
    c.save();
    c.translate(e.x, e.y);
    c.scale(e.direction.toDouble(), 1.0);
    c.drawImageRect(
      img,
      ui.Rect.fromLTWH(frame.x, frame.y, frame.w, frame.h),
      ui.Rect.fromLTWH(localX, localY, drawW, drawH),
      ui.Paint()..color = ui.Color.fromRGBO(255, 255, 255, opacity.clamp(0, 1)),
    );
    c.restore();
    if (!e.submerged && e.opacity >= 0.5) {
      e.bounds = ui.Rect.fromLTWH(
        e.x - drawW * 0.52,
        e.y - drawH,
        drawW * 1.04,
        drawH * 1.08,
      );
    }
    if (e.armorHits > 1) {
      final pipY = e.y - drawH - 8;
      for (int i = 0; i < e.armorHits; i++) {
        c.drawCircle(
          ui.Offset(e.x + (i - (e.armorHits - 1) / 2) * 12, pipY),
          5,
          ui.Paint()
            ..color = i == 0
                ? const ui.Color(0xffd9ff8b)
                : const ui.Color(0xff63d99a)
            ..style = ui.PaintingStyle.fill,
        );
        c.drawCircle(
          ui.Offset(e.x + (i - (e.armorHits - 1) / 2) * 12, pipY),
          5,
          ui.Paint()
            ..color = const ui.Color(0xe6263d27)
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    if (e.formationLeader && !e.totem) {
      final markerY = e.y - drawH - 10;
      final path = ui.Path();
      path.moveTo(e.x, markerY + 7);
      path.lineTo(e.x - 7, markerY - 5);
      path.lineTo(e.x + 7, markerY - 5);
      path.close();
      c.drawPath(
        path,
        ui.Paint()
          ..color = const ui.Color(0xf2ffe46e)
          ..style = ui.PaintingStyle.fill,
      );
      c.drawPath(
        path,
        ui.Paint()
          ..color = const ui.Color(0xe6463419)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (e.totem) {
      final boxW = (width * 0.42 < 146 ? width * 0.42 : 146).toDouble();
      final boxY = e.y + 8;
      c.drawRect(
        ui.Rect.fromLTWH(e.x - boxW / 2, boxY, boxW, 34),
        ui.Paint()..color = const ui.Color(0xe5132f26),
      );
      _text(
        c,
        e.totemLabel ?? '',
        e.x,
        boxY + 14,
        size: (width * 0.032).clamp(11, 999),
        color: const ui.Color(0xffffe783),
      );
      _text(
        c,
        e.totemRisk ?? '',
        e.x,
        boxY + 27,
        size: (width * 0.021).clamp(8, 999),
        color: const ui.Color(0xffd7ebc9),
      );
    }
    if (e.rare) {
      final tw = 3 + math.sin(input.now * 7 + e.phase) * 1.5;
      c.drawCircle(
        ui.Offset(e.x + targetHeight * 0.42, e.y - targetHeight * 0.88),
        tw,
        ui.Paint()..color = const ui.Color(0xf2fff79c),
      );
    }
  }

  void _challengeOverlay(ui.Canvas c, RenderInput input) {
    final ch = input.stage.challenge;
    if (ch == 'sandstorm' && input.challengeActive) {
      c.drawRect(
        ui.Rect.fromLTWH(0, 0, width, height),
        ui.Paint()..color = const ui.Color(0x2ecf913f),
      );
      for (int i = 0; i < 11; i++) {
        final y = ((i * 73 + input.now * 92) % (height + 80)) - 40;
        final p = ui.Path();
        p.moveTo(-30, y);
        p.lineTo(width + 30, y - 45);
        c.drawPath(
          p,
          ui.Paint()
            ..color = ui.Color.fromRGBO(255, 224, 150, 0.08 + (i % 3) * 0.04)
            ..strokeWidth = 3 + (i % 4),
        );
      }
    } else if (ch == 'camouflage' && input.challengeActive) {
      final g = ui.Gradient.linear(
        ui.Offset(0, height * 0.2),
        ui.Offset(width, height * 0.75),
        [
          const ui.Color(0x1f206b3d),
          const ui.Color(0x665d9d5b),
          const ui.Color(0x2616482f),
        ],
      );
      c.drawRect(
        ui.Rect.fromLTWH(0, height * 0.16, width, height * 0.68),
        ui.Paint()..shader = g,
      );
    } else if (ch == 'tide' && input.challengeActive) {
      final tideTop = height * (0.63 + math.sin(input.now * 1.8) * 0.045);
      final g = ui.Gradient.linear(
        ui.Offset(0, tideTop),
        ui.Offset(0, height),
        [const ui.Color(0x4765e5eb), const ui.Color(0x330d648e)],
      );
      c.drawRect(
        ui.Rect.fromLTWH(0, tideTop, width, height - tideTop),
        ui.Paint()..shader = g,
      );
    } else if (ch == 'bubble') {
      for (int i = 0; i < 18; i++) {
        final radius = 6 + (i % 5) * 4;
        final x = (i * 83 + math.sin(input.now + i) * 36) % (width + 40) - 20;
        final y =
            height - ((input.now * (24 + i % 4 * 7) + i * 67) % (height + 80));
        c.drawCircle(
          ui.Offset(x, y),
          radius.toDouble(),
          ui.Paint()
            ..color = const ui.Color(0x56d4fbff)
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    } else if (ch == 'heat') {
      c.drawRect(
        ui.Rect.fromLTWH(0, 0, width, height),
        ui.Paint()
          ..color = ui.Color.fromRGBO(
            255,
            126,
            51,
            0.07 + math.sin(input.now * 3) * 0.025,
          ),
      );
      final p = ui.Path();
      for (double y = height * 0.25; y < height; y += 58) {
        for (double x = 0; x <= width; x += 20) {
          final wy = y + math.sin(x * 0.04 + input.now * 4) * 5;
          if (x == 0)
            p.moveTo(x, wy);
          else
            p.lineTo(x, wy);
        }
      }
      c.drawPath(
        p,
        ui.Paint()
          ..color = const ui.Color(0x28ffe69c)
          ..strokeWidth = 3,
      );
    } else if (ch == 'dark') {
      final cx = width * (0.5 + math.sin(input.now * 0.65) * 0.32);
      final cy = height * (0.45 + math.cos(input.now * 0.53) * 0.22);
      final g = ui.Gradient.radial(
        ui.Offset(cx, cy),
        (width > height ? width : height) * 0.62,
        [
          const ui.Color(0x08080f25),
          const ui.Color(0x2e080f25),
          const ui.Color(0xb804081c),
        ],
        [0.0, 0.46, 1.0],
        ui.TileMode.clamp,
        null,
        ui.Offset(cx, cy),
        45,
      );
      c.drawRect(ui.Rect.fromLTWH(0, 0, width, height), ui.Paint()..shader = g);
    } else if (ch == 'snow') {
      for (int i = 0; i < 42; i++) {
        final x = (i * 61 + input.now * (18 + i % 5 * 4)) % (width + 30) - 15;
        final y = (i * 47 + input.now * (38 + i % 4 * 9)) % (height + 30) - 15;
        final radius = 1.5 + (i % 4);
        c.drawCircle(
          ui.Offset(x, y),
          radius,
          ui.Paint()
            ..color = ui.Color.fromRGBO(244, 253, 255, 0.28 + (i % 3) * 0.13),
        );
      }
    } else if (ch == 'portal' || ch == 'chaos') {
      final g = ui.Gradient.radial(
        ui.Offset(width * 0.5, height * 0.52),
        (width > height ? width : height) * 0.72,
        [
          const ui.Color(0x00ad80ff),
          ui.Color.fromRGBO(
            111,
            65,
            191,
            0.14 + math.sin(input.now * 2) * 0.04,
          ),
        ],
        [0.0, 1.0],
        ui.TileMode.clamp,
        null,
        ui.Offset(width * 0.5, height * 0.52),
        (width < height ? width : height) * 0.34,
      );
      c.drawRect(ui.Rect.fromLTWH(0, 0, width, height), ui.Paint()..shader = g);
    }
  }

  String _effectSheetKey(String type) {
    if (type.startsWith('guardian_') ||
        type == 'armor_crack' ||
        type == 'dive_ripple')
      return 'GUARDIAN_EFFECTS';
    if (type.startsWith('totem_') ||
        type.startsWith('formation_') ||
        type.startsWith('mutator_'))
      return 'TOTEM_EFFECTS';
    if (type.startsWith('rare_') || type.startsWith('wave_'))
      return 'WAVE_RARE_EFFECTS';
    if (type.startsWith('skill_')) return 'EFFECTS_SKILLS';
    return 'EFFECTS_SHEET';
  }

  List<Frame>? _effectFrames(String sheetKey, String type) {
    final direct = animations['$sheetKey:$type'];
    if (direct != null) return direct;
    for (final entry in animations.entries) {
      if (entry.key.endsWith(':$type')) return entry.value;
    }
    return null;
  }

  void _effects(ui.Canvas c, RenderInput input) {
    for (final e in input.effects) {
      final sheetKey = _effectSheetKey(e.type);
      final frames = _effectFrames(sheetKey, e.type);
      if (frames == null || frames.isEmpty) continue;
      final guardianEffect =
          e.type.startsWith('guardian_') ||
          e.type == 'armor_crack' ||
          e.type == 'dive_ripple';
      final totemEffect =
          e.type.startsWith('totem_') ||
          e.type.startsWith('formation_') ||
          e.type.startsWith('mutator_');
      final waveEffect =
          e.type.startsWith('rare_') || e.type.startsWith('wave_');
      final frameTime = guardianEffect || totemEffect || waveEffect
          ? 0.11
          : (e.type.startsWith('skill_') ? 0.14 : 0.07);
      final duration = guardianEffect || totemEffect || waveEffect
          ? 0.62
          : (e.type.startsWith('skill_') ? 0.72 : 0.36);
      final idx = (e.age / frameTime).floor().clamp(0, frames.length - 1);
      final frame = frames[idx];
      final img = images[sheetKey];
      if (img == null) continue;
      final size = e.size;
      final scale = size / (frame.w > frame.h ? frame.w : frame.h);
      c.save();
      c.drawImageRect(
        img,
        ui.Rect.fromLTWH(frame.x, frame.y, frame.w, frame.h),
        ui.Rect.fromLTWH(
          e.x - frame.w * scale * 0.5,
          e.y - frame.h * scale * 0.5,
          frame.w * scale,
          frame.h * scale,
        ),
        ui.Paint()
          ..color = ui.Color.fromRGBO(
            255,
            255,
            255,
            (1 - e.age / duration).clamp(0, 1),
          ),
      );
      c.restore();
      if (e.label.isNotEmpty) {
        _text(
          c,
          e.label,
          e.x,
          e.y - 38 - e.age * 42,
          size: (width * 0.045).clamp(15, 999),
          color: e.negative
              ? const ui.Color(0xff6665ff)
              : const ui.Color(0xfffff4a5),
          stroke: 4,
          strokeColor: const ui.Color(0xd93d2f13),
        );
      }
    }
  }

  void _mutatorOverlay(ui.Canvas c, RenderInput input) {
    if (input.mutator == null) return;
    final colors = {
      'sun': [const ui.Color(0x00ffc944), const ui.Color(0x33ff992d)],
      'moon': [const ui.Color(0x0074aaff), const ui.Color(0x3d3d3591)],
      'storm': [const ui.Color(0x0063e5ff), const ui.Color(0x33207697)],
      'bloom': [const ui.Color(0x006eec98), const ui.Color(0x34348e58)],
    };
    final pair = colors[input.mutator!.type]!;
    final g = ui.Gradient.radial(
      ui.Offset(width * 0.5, height * 0.52),
      (width > height ? width : height) * 0.72,
      [pair[0], pair[1]],
      [0.0, 1.0],
      ui.TileMode.clamp,
      null,
      ui.Offset(width * 0.5, height * 0.52),
      (width < height ? width : height) * 0.32,
    );
    c.drawRect(ui.Rect.fromLTWH(0, 0, width, height), ui.Paint()..shader = g);
  }

  void render(ui.Canvas c, RenderInput input) {
    c.drawColor(const ui.Color(0xff000000), ui.BlendMode.src);
    c.save();
    _cover(c, images[input.stage.bg] ?? images.values.first);
    _zoneTreatment(c, input.stage.zones);
    final sorted = [...input.entities]..sort((a, b) => a.y.compareTo(b.y));
    for (final e in sorted) _entity(c, e, input);
    _challengeOverlay(c, input);
    _mutatorOverlay(c, input);
    _effects(c, input);
    if (input.freezeTime > 0) {
      final g = ui.Gradient.radial(
        ui.Offset(width * 0.5, height * 0.52),
        (width > height ? width : height) * 0.72,
        [
          const ui.Color(0x00b4f5ff),
          const ui.Color(0x1658d5f5),
          const ui.Color(0x52adf5ff),
        ],
        [0.0, 0.72, 1.0],
        ui.TileMode.clamp,
        null,
        ui.Offset(width * 0.5, height * 0.52),
        (width < height ? width : height) * 0.18,
      );
      c.drawRect(ui.Rect.fromLTWH(0, 0, width, height), ui.Paint()..shader = g);
    }
    if (input.paused) {
      c.drawRect(
        ui.Rect.fromLTWH(0, 0, width, height),
        ui.Paint()..color = const ui.Color(0x5c0f1f1a),
      );
    }
    c.restore();
  }
}
