// Parsed sprite-sheet frame data, ported concept from game js/game/assets.js + renderer.js.
import 'dart:ui' as ui;

class Frame {
  final double x;
  final double y;
  final double w;
  final double h;
  final double ax;
  final double ay;
  const Frame(this.x, this.y, this.w, this.h, this.ax, this.ay);
}

// Returns mapping animationName -> frames, built from a sheet JSON.
Map<String, List<Frame>> parseSheet(Map<String, dynamic> json) {
  final animations = json['animations'] as List<dynamic>;
  final map = <String, List<Frame>>{};
  for (final anim in animations) {
    final name = anim['name'] as String;
    final fl = anim['frames'] as List<dynamic>;
    final frames = <Frame>[];
    for (final f in fl) {
      final source = f['source'] as Map<String, dynamic>;
      final content = (f['content'] as Map<String, dynamic>?) ?? source;
      final anchor = f['anchor'] as Map<String, dynamic>;
      frames.add(Frame(
        (content['x'] as num).toDouble(),
        (content['y'] as num).toDouble(),
        (content['w'] as num).toDouble(),
        (content['h'] as num).toDouble(),
        (anchor['x'] as num).toDouble(),
        (anchor['y'] as num).toDouble(),
      ));
    }
    map[name] = frames;
  }
  return map;
}
