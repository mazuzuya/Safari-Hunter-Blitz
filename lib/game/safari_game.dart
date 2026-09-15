import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'entities.dart';
import 'renderer.dart';
import 'audio.dart';
import 'frame_data.dart';

const List<int> COMBO_MULTIPLIERS = [1, 2, 3, 5, 8, 10];

class SaveData {
  int version = 1;
  int unlocked = 1;
  List<int> stars = List.filled(20, 0);
  int coins = 0;
  int seeds = 0;
  int gems = 0;
  int bestScore = 0;
  Map<String, int> upgrades = {
    'time': 0,
    'radar': 0,
    'score': 0,
    'freeze': 0,
    'bait': 0,
    'burst': 0,
  };
  SaveData();
  SaveData.fromJson(Map<String, dynamic> r) {
    version = r['version'] ?? 1;
    unlocked = r['unlocked'] ?? 1;
    stars = List<int>.from(
      (r['stars'] as List?)?.map((e) => e as int) ?? List.filled(20, 0),
    );
    while (stars.length < 20) stars.add(0);
    coins = r['coins'] ?? 0;
    seeds = r['seeds'] ?? 0;
    gems = r['gems'] ?? 0;
    bestScore = r['bestScore'] ?? 0;
    final up = r['upgrades'] as Map?;
    if (up != null) {
      upgrades = {
        'time': up['time'] ?? 0,
        'radar': up['radar'] ?? 0,
        'score': up['score'] ?? 0,
        'freeze': up['freeze'] ?? 0,
        'bait': up['bait'] ?? 0,
        'burst': up['burst'] ?? 0,
      };
    }
  }
  Map<String, dynamic> toJson() => {
    'version': version,
    'unlocked': unlocked,
    'stars': stars,
    'coins': coins,
    'seeds': seeds,
    'gems': gems,
    'bestScore': bestScore,
    'upgrades': upgrades,
  };
}

SaveData safeSave(dynamic raw) {
  if (raw == null || raw['version'] != 1) return SaveData();
  final s = SaveData.fromJson(raw);
  for (int i = 0; i < 20; i++) {
    s.stars[i] = s.stars[i].clamp(0, 3);
  }
  return s;
}

enum Screen { none, start, result, stages, shop, pause }

class HudTarget {
  final String id;
  final String name;
  int remaining;
  HudTarget(this.id, this.name, this.remaining);
}

class StageNode {
  final int index;
  final String name;
  final String challengeName;
  final int stars;
  final bool locked;
  StageNode(this.index, this.name, this.challengeName, this.stars, this.locked);
}

class ShopEntry {
  final String id;
  final String name;
  final String detail;
  final int max;
  final List<int> prices;
  ShopEntry(this.id, this.name, this.detail, this.max, this.prices);
}

class SafariController extends ChangeNotifier {
  Screen screen = Screen.start;
  int stageIndex = 0;
  String stageName = '';
  int area = 1;
  String challengeName = '';
  int coins = 0;
  int seeds = 0;
  int gems = 0;
  double time = 45;
  int wave = 1;
  int score = 0;
  int combo = 0;
  double pressure = 0;
  bool challengeActive = false;
  String? mutatorName;
  double mutatorTime = 0;
  List<HudTarget> targets = [];
  int guardianHp = 0;
  int guardianMaxHp = 0;
  String guardianName = '';
  bool guardianVisible = false;
  Map<String, bool> skillsUsed = {
    'freeze': false,
    'bait': false,
    'burst': false,
  };
  Map<String, int> skillCharges = {'freeze': 1, 'bait': 1, 'burst': 1};
  bool started = false;
  String status = 'Memuat hewan HD...';
  // result
  bool resultSuccess = false;
  int resultStars = 0;
  String resultTitle = '';
  String resultFacts = '';
  int bestScore = 0;
  // stages/shop
  List<StageNode> stageNodes = [];
  List<ShopEntry> shopItems = [];
  String toast = '';
  bool toastVisible = false;
  bool _resumeAfterModal = false;
  Screen modalReturn = Screen.none;

  void notify() => notifyListeners();
}

class SafariGame extends FlameGame {
  final SafariController controller;
  final AudioBus audio = AudioBus();
  final Tuning tuning = Tuning();

  late Renderer renderer;
  final Map<String, ui.Image> _images = {};
  final Map<String, List<Frame>> _animations = {};

  String mode = 'loading';
  int stageIndex = 0;
  Stage stage = STAGES[0];
  List<String> targetIds = [];
  Map<String, int> targets = {};
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  double comboAge = 0;
  double time = 45;
  double totalTime = 45;
  double spawnTimer = 0;
  double elapsed = 0;
  List<Entity> entities = [];
  List<Effect> effects = [];
  bool paused = false;
  int radarLevel = 0;
  double freezeTime = 0;
  Map<String, bool> skillsUsed = {
    'freeze': false,
    'bait': false,
    'burst': false,
  };
  Map<String, int> skillCharges = {'freeze': 1, 'bait': 1, 'burst': 1};
  bool challengeActive = false;
  double challengeEvent = 5;
  double pressure = 0;
  Guardian? guardianSpec;
  Entity? guardianEntity;
  int guardianHp = 0;
  int guardianMaxHp = 0;
  bool guardianSpawned = false;
  bool guardianDefeated = true;
  bool totemOffered = false;
  List<Entity> totemChoices = [];
  double totemChoiceTime = 0;
  Mutator? mutator;
  double mutatorTime = 0;
  double formationEvent = 7;
  int formationId = 0;
  int wave = 1;
  SaveData save = SaveData();
  bool assetsReady = false;
  SharedPreferences? _preferences;

  int _entityId = 0;
  double _lastFrame = 0;
  double _toastTimer = 0;
  String _lastHudSig = '';
  final math.Random _rng = math.Random();

  SafariGame(this.controller);

  Future<void> _loadSave() async {
    _preferences = await SharedPreferences.getInstance();
    final encoded = _preferences!.getString('safari_hunter_save');
    if (encoded == null) return;
    try {
      save = safeSave(json.decode(encoded));
    } catch (_) {
      save = SaveData();
    }
  }

  Future<void> _persistSave() async {
    final prefs = _preferences ??= await SharedPreferences.getInstance();
    await prefs.setString('safari_hunter_save', jsonEncode(save.toJson()));
  }

  int _skillUses(String skill) =>
      math.min(3, 1 + math.min(2, save.upgrades[skill]!));

  int _skillBonus(String skill) => math.max(0, save.upgrades[skill]! - 2);

  String _imageKey(String file) {
    var k = file.replaceAll('.webp', '');
    if (k.endsWith('-transparent'))
      k = k.substring(0, k.length - '-transparent'.length);
    return k.toUpperCase();
  }

  @override
  Future<void> onLoad() async {
    try {
      await _loadSave();
      final imgDir = 'assets/images';
      final jsonDir = 'assets/json';
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final keys = manifest.listAssets();
      final imgFiles = keys
          .where((k) => k.startsWith(imgDir) && k.endsWith('.webp'))
          .toList();
      for (final path in imgFiles) {
        final file = path.split('/').last;
        final bytes = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        final img = frame.image;
        codec.dispose();
        _images[_imageKey(file)] = img;
      }
      final jsonFiles = keys
          .where((k) => k.startsWith(jsonDir) && k.endsWith('.frames.json'))
          .toList();
      for (final path in jsonFiles) {
        final file = path.split('/').last;
        var sheetKey = file.replaceAll('.frames.json', '');
        if (sheetKey.endsWith('-transparent')) {
          sheetKey = sheetKey.substring(
            0,
            sheetKey.length - '-transparent'.length,
          );
        }
        sheetKey = sheetKey.toUpperCase();
        final txt = await rootBundle.loadString(path);
        final data = json.decode(txt) as Map<String, dynamic>;
        final anims = parseSheet(data);
        anims.forEach((name, frames) {
          _animations['$sheetKey:$name'] = frames;
        });
      }
      renderer = Renderer(_images, _animations);
      renderer.resize(canvasSize.x, canvasSize.y);
      assetsReady = true;
      controller.status = 'Ketuk untuk mulai';
      controller.started = true;
      controller.screen = Screen.start;
      configureStage(0, true);
      controller.notify();
    } catch (e, stack) {
      controller.status = 'Gagal memuat: $e';
      controller.started = true;
      controller.notify();
      rethrow;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!assetsReady) return;
    renderer.resize(size.x, size.y);
  }

  T _randomItem<T>(List<T> items) => items[_rng.nextInt(items.length)];

  Entity _makeEntity(Animal spec, bool idlePlacement) {
    final width = renderer.w;
    final fromLeft = _rng.nextDouble() < 0.6;
    final direction = fromLeft ? 1 : -1;
    final e = Entity(
      id: ++_entityId,
      spec: spec,
      x: idlePlacement
          ? _rng.nextDouble() * width
          : (fromLeft ? -110.0 : width + 110.0),
      baseY: _pickY(spec.zone),
      y: 0,
      direction: direction,
      speedVariance: 0.82 + _rng.nextDouble() * 0.38,
      phase: _rng.nextDouble() * 10,
      frameTime: math.max(0.085, 0.15 / stage.speed),
      rare:
          _rng.nextDouble() <
          tuning.rareChance * (mutator?.type == 'bloom' ? 2 : 1) +
              (stageIndex >= 15 ? 0.04 : 0),
      visualScale:
          (0.9 + _rng.nextDouble() * 0.2) / math.pow(stage.worldScale, 0.55),
      opacity: 1,
      decoy: false,
      guardian: false,
      totem: false,
      formationLeader: false,
      behavior: 'steady',
      armorHits: 1,
      submerged: false,
      wasSubmerged: false,
      nextFeint: 0,
      elite: false,
    );
    e.y = e.baseY;
    return e;
  }

  double _pickY(String zone) {
    final height = renderer.h;
    final expansion = math.min(0.06, (stage.worldScale - 1) * 0.11);
    // Keep animals out of the bottom 25% so they aren't hidden by the HUD.
    final bottomLimit = height * 0.75;
    if (zone == 'sky')
      return height *
          (0.16 - expansion + _rng.nextDouble() * (0.14 + expansion));
    if (zone == 'water')
      return bottomLimit - _rng.nextDouble() * height * 0.16;
    return math.min(
      bottomLimit,
      height * (0.46 - expansion + _rng.nextDouble() * (0.22 + expansion)),
    );
  }

  List<String> _targetPool() {
    return targetIds
        .where(
          (id) =>
              (targets[id] ?? 0) > 0 &&
              stage.zones.contains(ANIMAL_BY_ID[id]!.zone),
        )
        .toList();
  }

  List<Animal> _activeAnimalPool() {
    final waveIds = wave >= 5
        ? [...WAVE_ROSTERS[4]!, ...WAVE_ROSTERS[5]!]
        : (wave >= 4 ? WAVE_ROSTERS[4]! : <String>[]);
    return [...stage.pool, ...waveIds]
        .map((id) => ANIMAL_BY_ID[id]!)
        .where((e) => e != null && stage.zones.contains(e.zone))
        .toList();
  }

  List<Animal> _localAnimalPool() {
    return stage.localPool
        .map((id) => ANIMAL_BY_ID[id]!)
        .where((e) => e != null && stage.zones.contains(e.zone))
        .toList();
  }

  void _applyWaveTraits(Entity e, bool isTarget) {
    if (e.spec.waveTier == 4) {
      e.behavior = 'dart';
      e.speedVariance = tuning.wave4Speed * (0.96 + _rng.nextDouble() * 0.28);
      e.frameTime = math.max(0.06, e.frameTime * 0.72);
    } else if (e.spec.waveTier == 5) {
      e.elite = true;
      e.behavior = 'steady';
      e.speedVariance = 0.78 + _rng.nextDouble() * 0.22;
      e.armorHits = isTarget ? math.max(2, tuning.eliteTapCount.round()) : 1;
      e.visualScale *= 1.08;
    }
  }

  void _spawnAnimal([bool idlePlacement = false]) {
    final outstanding = _targetPool();
    final active = _activeAnimalPool();
    final local = _localAnimalPool();
    final rescueChance = time < totalTime * 0.3 ? 0.12 : 0;
    final targetChance =
        (0.46 +
                math.min(
                  0.84,
                  0.62 + stage.area * 0.016 - pressure * 0.12 + rescueChance,
                ))
            .clamp(0.46, 0.84);
    final chooseTarget =
        outstanding.isNotEmpty &&
        (_rng.nextDouble() < targetChance || entities.length < 2);
    final mirage =
        ['mirage', 'chaos'].contains(stage.challenge) &&
        outstanding.isNotEmpty &&
        !chooseTarget &&
        _rng.nextDouble() < 0.32;
    final distractorPool = (local.isNotEmpty && _rng.nextDouble() < 0.7)
        ? local
        : active;
    final spec = (chooseTarget || mirage)
        ? ANIMAL_BY_ID[_randomItem(outstanding)]!
        : _randomItem(distractorPool);
    final e = _makeEntity(spec, idlePlacement);
    e.decoy = mirage;
    final isTarget = (targets[spec.id] ?? 0) > 0 && !e.decoy;
    if (stage.area >= 5 && spec.zone == 'water' && _rng.nextDouble() < 0.48)
      e.behavior = 'dive';
    else if (stage.area >= 3 && spec.zone == 'sky' && _rng.nextDouble() < 0.52)
      e.behavior = 'swoop';
    else if (stage.area >= 4 && spec.size <= 60 && _rng.nextDouble() < 0.62)
      e.behavior = 'dart';
    else if (stage.area >= 7 && spec.zone == 'land' && _rng.nextDouble() < 0.34)
      e.behavior = 'feint';
    if (stage.area >= 6 &&
        isTarget &&
        spec.size >= 70 &&
        _rng.nextDouble() < 0.42)
      e.armorHits = 2;
    _applyWaveTraits(e, isTarget);
    if (e.decoy) e.rare = false;
    entities.add(e);
  }

  void configureStage(int index, [bool idle = false]) {
    stageIndex = index;
    stage = STAGES[index];
    targetIds = chooseTargets(index);
    targets = distributeTargets(targetIds, stage.total);
    score = 0;
    combo = 0;
    maxCombo = 0;
    comboAge = 0;
    totalTime = stage.time + save.upgrades['time']! * 3;
    time = totalTime;
    spawnTimer = 0;
    elapsed = 0;
    entities = [];
    effects = [];
    paused = false;
    radarLevel = save.upgrades['radar']!;
    freezeTime = 0;
    skillsUsed = {'freeze': false, 'bait': false, 'burst': false};
    skillCharges = {
      'freeze': _skillUses('freeze'),
      'bait': _skillUses('bait'),
      'burst': _skillUses('burst'),
    };
    challengeActive = false;
    challengeEvent = 4.5;
    pressure = 0;
    guardianSpec = GUARDIANS[index];
    guardianEntity = null;
    guardianMaxHp = guardianSpec != null
        ? math.max(1, (guardianSpec!.hp * tuning.guardianHpScale).ceil())
        : 0;
    guardianHp = guardianMaxHp;
    guardianSpawned = false;
    guardianDefeated = guardianSpec == null;
    totemOffered = false;
    totemChoices = [];
    totemChoiceTime = 0;
    mutator = null;
    mutatorTime = 0;
    formationEvent = 6.5 + _rng.nextDouble() * 2;
    formationId = 0;
    wave = 1;
    mode = idle ? 'idle' : 'playing';
    audio.setLevelBgm(stage.area);
    final opening = idle
        ? 7
        : math.min(12, 3 + ((stage.area - 1) * 0.9).floor());
    for (int i = 0; i < opening; i++) _spawnAnimal(true);
    _syncHud(force: true);
  }

  void beginStage([int index = -1]) {
    final idx = index < 0 ? stageIndex : index;
    controller.screen = Screen.none;
    configureStage(idx, false);
    _showToast('${stage.challengeName} - siapkan strategi');
  }

  void _effect(
    String type,
    double x,
    double y, [
    String label = '',
    bool negative = false,
    double size = 86,
  ]) {
    effects.add(Effect(type, x, y, 0, label, negative, size));
  }

  void _registerCorrect(Entity e) {
    combo += 1;
    maxCombo = math.max(maxCombo, combo);
    comboAge = 0;
    final mult =
        COMBO_MULTIPLIERS[math.min(
          COMBO_MULTIPLIERS.length - 1,
          math.max(0, combo - 1),
        )];
    final totemMult = mutator?.type == 'sun' ? 2 : 1;
    final points =
        (100 * mult * totemMult * (1 + save.upgrades['score']! * 0.1)).round();
    score += points;
    save.coins += 10;
    targets[e.spec.id] = (targets[e.spec.id] ?? 0) - 1;
    _effect('tap_burst', e.x, e.y - e.renderSize * 0.45, '+$points');
    audio.correct(combo);
    _persistSave();
  }

  void _registerRare(Entity e) {
    score += 750;
    save.gems += 2;
    if ((targets[e.spec.id] ?? 0) > 0)
      targets[e.spec.id] = targets[e.spec.id]! - 1;
    _effect(
      'rare_prism_burst',
      e.x,
      e.y - e.renderSize * 0.45,
      '+750  x2',
      false,
      170,
    );
    _effect('rare_paw_portal', e.x, e.y - e.renderSize * 0.45, '', false, 210);
    audio.rare();
    _persistSave();
  }

  void _registerWrong(Entity e) {
    score = math.max(0, score - 50);
    final penalty = mutator?.type == 'storm' ? 4 : 2;
    time = math.max(0, time - penalty);
    combo = 0;
    comboAge = 0;
    _effect('wrong_x', e.x, e.y - e.renderSize * 0.45, '-$penalty dtk', true);
    audio.wrong();
  }

  void _spawnGuardian() {
    if (guardianSpec == null || guardianSpawned || guardianDefeated) return;
    final spec = guardianSpec!;
    final e = _makeEntity(
      Animal(
        id: spec.id,
        name: spec.name,
        zone: spec.zone,
        sheet: spec.sheet,
        animation: spec.animation,
        row: 0,
        size: spec.size,
      ),
      true,
    );
    e.guardian = true;
    e.behavior = 'guardian';
    e.rare = false;
    e.decoy = false;
    e.armorHits = 1;
    e.visualScale = 1;
    e.speedVariance = 0.42;
    e.x = renderer.w * 0.5;
    e.baseY = _pickY(spec.zone);
    e.y = e.baseY;
    entities.add(e);
    guardianEntity = e;
    guardianSpawned = true;
    _effect(
      'guardian_arrival',
      renderer.w * 0.5,
      renderer.h * 0.5,
      'PENJAGA DATANG',
      false,
      math.min(renderer.w, renderer.h) * 0.76,
    );
    audio.guardian(guardianHp);
    _showToast('${spec.name} menjaga jalan!');
  }

  bool _hitGuardian(Entity? e, [bool fromSkill = false]) {
    if (e == null || e != guardianEntity || guardianDefeated) return false;
    guardianHp = math.max(0, guardianHp - 1);
    final points =
        ((fromSkill ? 180 : 260) *
                (mutator?.type == 'sun' ? 2 : 1) *
                (1 + pressure * 0.5))
            .round();
    score += points;
    _effect(
      'guardian_hit',
      e.x,
      e.y - e.renderSize * 0.5,
      '+$points',
      false,
      130,
    );
    audio.guardian(guardianHp);
    e.direction *= -1;
    if (guardianHp == 0) {
      guardianDefeated = true;
      guardianEntity = null;
      entities.removeWhere((c) => c == e);
      time += 3;
      _effect(
        'guardian_arrival',
        e.x,
        e.y - e.renderSize * 0.4,
        'PENJAGA TAKLUK! +3 dtk',
        false,
        170,
      );
      _showToast('Penjaga takluk-jalan terbuka!');
    }
    return true;
  }

  void _spawnTotemChoice() {
    if (stage.area < 4 || totemOffered || mode != 'playing') return;
    final types = TOTEMS.keys.toList()..shuffle();
    final chosen = types.take(2).toList();
    totemChoices = chosen.map((type) {
      final spec = TOTEMS[type]!;
      final e = _makeEntity(
        Animal(
          id: spec.id,
          name: spec.name,
          zone: spec.zone,
          sheet: spec.sheet,
          animation: spec.animation,
          row: 0,
          size: spec.size,
        ),
        true,
      );
      e.totem = true;
      e.totemType = type;
      e.totemLabel = spec.name;
      e.totemRisk = spec.risk;
      e.rare = false;
      e.visualScale = math.max(0.78, 1 / math.pow(stage.worldScale, 0.2));
      e.speedVariance = 0;
      e.x = renderer.w * (type == chosen.first ? 0.27 : 0.73);
      e.baseY = renderer.h * 0.61;
      e.y = e.baseY;
      return e;
    }).toList();
    entities.addAll(totemChoices);
    totemOffered = true;
    totemChoiceTime = 7.5;
    audio.totem();
    _showToast('Totem Liar muncul-pilih risiko!');
  }

  void _spawnBloomDecoys(int count) {
    final outstanding = _targetPool();
    if (outstanding.isEmpty) return;
    for (int i = 0; i < count; i++) {
      final e = _makeEntity(ANIMAL_BY_ID[_randomItem(outstanding)]!, true);
      e.decoy = true;
      e.rare = false;
      e.x = renderer.w * (0.08 + _rng.nextDouble() * 0.84);
      entities.add(e);
    }
  }

  void _activateTotem(Entity e) {
    final type = e.totemType!;
    final spec = TOTEMS[type]!;
    entities.removeWhere((c) => c.totem);
    totemChoices = [];
    totemChoiceTime = 0;
    mutator = Mutator(type, spec.name);
    mutatorTime = tuning.totemDuration;
    if (type == 'storm') {
      for (int i = 0; i < 8; i++) _spawnTargetInstant();
    } else if (type == 'bloom') {
      time += 3;
      _spawnBloomDecoys(5);
    }
    audio.totem();
    _showToast('${spec.name}: ${spec.risk}');
    _syncHud(force: true);
  }

  bool _spawnTargetInstant() {
    final outstanding = _targetPool();
    if (outstanding.isEmpty) return false;
    final e = _makeEntity(ANIMAL_BY_ID[_randomItem(outstanding)]!, true);
    e.x = renderer.w * (0.08 + _rng.nextDouble() * 0.84);
    entities.add(e);
    return true;
  }

  void useSkill(String skill) {
    if (mode != 'playing' || paused || (skillCharges[skill] ?? 0) <= 0) return;
    final w = renderer.w;
    final h = renderer.h;
    if (skill == 'freeze') {
      freezeTime = 4.0 + _skillBonus('freeze');
      _effect(
        'skill_freeze',
        w * 0.5,
        h * 0.52,
        'BEKU ${freezeTime.toInt()} dtk',
        false,
        math.min(w, h) * 0.68,
      );
      _showToast('Waktu dan kawanan dibekukan');
    } else if (skill == 'bait') {
      final count = 5 + _skillBonus('bait');
      int spawned = 0;
      for (int i = 0; i < count; i++) if (_spawnTargetInstant()) spawned++;
      _effect(
        'skill_bait',
        w * 0.5,
        h * 0.55,
        '+$spawned TARGET',
        false,
        math.min(w, h) * 0.62,
      );
      _showToast('Target terpancing ke layar');
    } else if (skill == 'burst') {
      final count = 3 + _skillBonus('burst');
      final caught = entities
          .where((e) => !e.decoy && (targets[e.spec.id] ?? 0) > 0)
          .take(count)
          .toList();
      for (final e in caught) {
        if ((targets[e.spec.id] ?? 0) > 0) _registerCorrect(e);
      }
      final guardianDamaged = _hitGuardian(guardianEntity, true);
      entities.removeWhere((e) => caught.contains(e));
      _effect(
        'skill_burst',
        w * 0.5,
        h * 0.55,
        '${caught.length} TERTANGKAP',
        false,
        math.min(w, h) * 0.72,
      );
      if (caught.isEmpty && !guardianDamaged) {
        _showToast('Belum ada target terlihat');
        return;
      }
      _showToast('Ledakan safari!');
    }
    skillCharges[skill] = skillCharges[skill]! - 1;
    skillsUsed[skill] = skillCharges[skill] == 0;
    audio.rare();
    _syncHud(force: true);
    if (_allTargetsDone()) finishStage(true);
  }

  void handleTap(double x, double y) {
    if (mode != 'playing' || paused) return;
    Entity? entity;
    for (int i = entities.length - 1; i >= 0; i--) {
      final candidate = entities[i];
      if (candidate.submerged || candidate.opacity < 0.5) continue;
      final b = candidate.bounds;
      if (b != null &&
          x >= b.left &&
          x <= b.right &&
          y >= b.top &&
          y <= b.bottom) {
        entity = candidate;
        break;
      }
    }
    if (entity == null) {
      _effect('tap_burst', x, y, '', false, 54);
      return;
    }
    if (entity!.totem) {
      _activateTotem(entity!);
      return;
    }
    if (entity!.guardian) {
      _hitGuardian(entity!);
      if (_allTargetsDone()) finishStage(true);
      return;
    }
    if (entity!.armorHits > 1) {
      entity!.armorHits -= 1;
      score += 25;
      _effect(
        'armor_crack',
        entity!.x,
        entity!.y - entity!.renderSize * 0.5,
        'ZIRAH RETAK',
        false,
        96,
      );
      audio.correct(1);
      _syncHud(force: true);
      return;
    }
    if (entity!.decoy)
      _registerWrong(entity!);
    else if (entity!.rare)
      _registerRare(entity!);
    else if ((targets[entity!.spec.id] ?? 0) > 0)
      _registerCorrect(entity!);
    else
      _registerWrong(entity!);
    entities.removeWhere((c) => c == entity!);
    _syncHud(force: true);
    if (_allTargetsDone()) finishStage(true);
  }

  bool _allTargetsDone() {
    final done = targets.values.every((c) => c <= 0);
    return wave >= 5 && done && (guardianSpec == null || guardianDefeated);
  }

  int _stageStars() {
    final ratio = time / totalTime;
    if (ratio > 0.5) return 3;
    if (ratio > 0.2) return 2;
    return 1;
  }

  void finishStage(bool success) {
    if (mode != 'playing') return;
    mode = 'result';
    paused = true;
    controller.screen = Screen.result;
    int stars = 0;
    int seedReward = 0;
    if (success) {
      stars = _stageStars();
      final prev = save.stars[stageIndex];
      save.stars[stageIndex] = math.max(prev, stars);
      seedReward = prev > 0 && stars <= prev ? 50 : stars * 100;
      save.seeds += seedReward;
      save.unlocked = math.min(20, math.max(save.unlocked, stageIndex + 2));
      audio.clear();
      _effect(
        'leaf_confetti',
        renderer.w * 0.5,
        renderer.h * 0.48,
        '',
        false,
        180,
      );
    }
    save.bestScore = math.max(save.bestScore, score.round());
    final title = success ? 'BERHASIL!' : 'WAKTU HABIS';
    controller.resultSuccess = success;
    controller.resultStars = stars;
    controller.resultTitle = title;
    controller.resultFacts =
        '${stage.challengeName} · Combo x$maxCombo · +$seedReward Bintang · Terbaik ${save.bestScore}';
    controller.bestScore = save.bestScore;
    _persistSave();
    controller.notify();
  }

  void showStages() {
    final wasPlaying = mode == 'playing';
    paused = true;
    controller.stageNodes = [
      for (int i = 0; i < STAGES.length; i++)
        StageNode(
          i,
          STAGES[i].name,
          STAGES[i].challengeName,
          save.stars[i],
          false,
        ),
    ];
    controller.modalReturn =
        controller.screen == Screen.shop && controller._resumeAfterModal
        ? Screen.none
        : controller.screen;
    controller._resumeAfterModal = wasPlaying;
    controller.screen = Screen.stages;
    controller.notify();
  }

  List<int> _upgradePrices(int startingPrice) => [
    for (int i = 0; i < 10; i++) (startingPrice * math.pow(1.1, i)).round(),
  ];

  void showShop() {
    paused = true;
    controller.modalReturn = controller.screen;
    controller._resumeAfterModal = mode == 'playing';
    controller.shopItems = [
      ShopEntry(
        'time',
        'Waktu Ekstra',
        '+3 detik / level',
        10,
        _upgradePrices(50),
      ),
      ShopEntry(
        'radar',
        'Zoom Radar',
        'Tanda target makin jelas',
        10,
        _upgradePrices(40),
      ),
      ShopEntry(
        'score',
        'Skor Bonus',
        '+10% skor / level',
        10,
        _upgradePrices(60),
      ),
      ShopEntry(
        'freeze',
        'Beku Lebih Lama',
        'Level 1-2: +1 charge, lalu +1 detik',
        10,
        _upgradePrices(80),
      ),
      ShopEntry(
        'bait',
        'Umpan Rimbun',
        'Level 1-2: +1 charge, lalu +1 target',
        10,
        _upgradePrices(90),
      ),
      ShopEntry(
        'burst',
        'Ledakan Lebar',
        'Level 1-2: +1 charge, lalu +1 target',
        10,
        _upgradePrices(110),
      ),
    ];
    controller.screen = Screen.shop;
    controller.notify();
  }

  void buyUpgrade(String id, int price) {
    if (save.seeds < price) {
      _showToast('Bintang belum cukup');
      return;
    }
    save.seeds -= price;
    save.upgrades[id] = save.upgrades[id]! + 1;
    if (id == 'time') {
      totalTime += 3;
      time += 3;
    } else if (id == 'radar') {
      radarLevel = save.upgrades['radar']!;
    } else if (['freeze', 'bait', 'burst'].contains(id) &&
        save.upgrades[id]! <= 2) {
      skillCharges[id] = (skillCharges[id] ?? 0) + 1;
      skillsUsed[id] = false;
    }
    _syncHud(force: true);
    _persistSave();
  }

  void enableTestMoney() {
    save.seeds = 9999;
    _showToast('Mode testing: 9999 Bintang Safari');
    _syncHud(force: true);
    _persistSave();
  }

  void closeModal() {
    controller.screen = controller.modalReturn;
    controller.modalReturn = Screen.none;
    if (controller.screen == Screen.none &&
        controller._resumeAfterModal &&
        mode == 'playing') {
      paused = false;
    }
    controller._resumeAfterModal = false;
    controller.notify();
  }

  void togglePause() {
    if (mode != 'playing') return;
    paused = !paused;
    controller.screen = paused ? Screen.pause : Screen.none;
    controller.notify();
  }

  void startGame() {
    if (!assetsReady) return;
    audio.unlock();
    controller.screen = Screen.none;
    beginStage(0);
  }

  void _showToast(String msg) {
    controller.toast = msg;
    controller.toastVisible = true;
    _toastTimer = 1.0;
    controller.notify();
  }

  void _syncRendererSize() {
    final cs = canvasSize;
    if (cs.x > 1 && cs.y > 1 && (renderer.w != cs.x || renderer.h != cs.y)) {
      renderer.resize(cs.x, cs.y);
    }
  }

  void _syncHud({bool force = false}) {
    controller.stageIndex = stageIndex;
    controller.stageName = stage.name;
    controller.area = stage.area;
    controller.challengeName = stage.challengeName;
    controller.coins = save.coins;
    controller.seeds = save.seeds;
    controller.gems = save.gems;
    controller.time = time;
    controller.wave = wave;
    controller.score = score.round();
    controller.combo = combo;
    controller.pressure = pressure;
    controller.challengeActive = challengeActive;
    controller.mutatorName = mutator?.name;
    controller.mutatorTime = mutatorTime;
    controller.targets = [
      for (final id in targetIds.where((id) => (targets[id] ?? 0) > 0))
        HudTarget(id, ANIMAL_BY_ID[id]!.name, targets[id]!),
    ];
    controller.guardianHp = guardianHp;
    controller.guardianMaxHp = guardianMaxHp;
    controller.guardianName = guardianSpawned
        ? guardianSpec?.name ?? ''
        : 'Penjaga mendekat';
    controller.guardianVisible = guardianSpec != null && !guardianDefeated;
    controller.skillsUsed = {...skillsUsed};
    controller.skillCharges = {...skillCharges};
    final sig =
        '${score.round()}|${combo}|${pressure.toStringAsFixed(2)}|${time.toStringAsFixed(1)}|${wave}|${mutator?.type ?? ''}|${controller.targets.length}|${guardianHp}|${skillsUsed.values.join('')}';
    if (force || sig != _lastHudSig) {
      _lastHudSig = sig;
      controller.notify();
    }
  }

  void _updateEntities(double dt, double now) {
    final width = renderer.w;
    double challengeSpeed = 1;
    switch (stage.challenge) {
      case 'current':
        challengeSpeed = 1.05 + math.sin(now * 2.4) * 0.38;
        break;
      case 'lava':
        challengeSpeed = challengeActive ? 1.72 : 0.92;
        break;
      case 'ice':
        challengeSpeed = 0.68 + (math.sin(now * 1.7)).abs() * 0.9;
        break;
      case 'chaos':
        challengeSpeed = 1.08 + (math.sin(now * 2.8)).abs() * 0.55;
        break;
    }
    double mutatorSpeed = 1;
    if (mutator?.type == 'sun')
      mutatorSpeed = 1.42;
    else if (mutator?.type == 'moon')
      mutatorSpeed = 0.72;
    else if (mutator?.type == 'storm')
      mutatorSpeed = 1.2;
    final baseSpeed =
        52 *
        stage.speed *
        tuning.speedScale *
        challengeSpeed *
        mutatorSpeed *
        (1 + pressure * 0.28);
    for (final e in entities) {
      if (e.totem) {
        e.y = e.baseY + math.sin(now * 2.8 + e.phase) * 10;
        e.opacity = 1;
        continue;
      }
      final ambushBoost = stage.challenge == 'ambush' && challengeActive
          ? 1.55
          : 1;
      double behaviorSpeed = 1;
      if (e.behavior == 'dart')
        behaviorSpeed = 0.75 + (math.sin(now * 5.5 + e.phase)).abs() * 1.25;
      if (e.behavior == 'guardian') behaviorSpeed = 0.42;
      e.x +=
          e.direction *
          baseSpeed *
          e.speedVariance *
          ambushBoost *
          behaviorSpeed *
          dt;
      double bob = e.spec.zone == 'land'
          ? math.sin(now * 5 + e.phase) * 1.5
          : math.sin(now * 2.8 + e.phase) * 8;
      if (stage.challenge == 'zigzag' && e.spec.zone == 'sky')
        bob += math.sin(now * 7 + e.phase) * 22;
      if (stage.challenge == 'tide' && e.spec.zone == 'water')
        bob += math.sin(now * 1.8 + e.phase) * 30;
      if (e.behavior == 'swoop') bob += math.sin(now * 4.8 + e.phase) * 28;
      e.y = e.baseY + bob;
      e.opacity = 1;
      if (e.behavior == 'dive') {
        final divePhase = (now + e.phase) % 5.2;
        e.submerged = divePhase > 3.55;
        if (e.submerged) e.opacity = 0.12;
        if (e.submerged && !e.wasSubmerged)
          _effect('dive_ripple', e.x, e.y - 8, '', false, 80);
        e.wasSubmerged = e.submerged;
      }
      if (e.behavior == 'feint' && now >= e.nextFeint) {
        e.direction *= -1;
        e.nextFeint = now + 2.4 + _rng.nextDouble() * 2.2;
      }
      if (stage.challenge == 'burrow' &&
          challengeActive &&
          e.spec.zone == 'land')
        e.opacity = 0.24;
      if (stage.challenge == 'ambush' &&
          challengeActive &&
          e.spec.zone == 'land')
        e.opacity = 0.34;
      if (e.guardian) {
        final edge = width * 0.12;
        if (e.x < edge) {
          e.x = edge;
          e.direction = 1;
        }
        if (e.x > width - edge) {
          e.x = width - edge;
          e.direction = -1;
        }
      }
      if (mode == 'idle' &&
          ((e.direction > 0 && e.x > width + 120) ||
              (e.direction < 0 && e.x < -120))) {
        e.x = e.direction > 0 ? -100 : width + 100;
      }
    }
    if (mode != 'idle') {
      entities.removeWhere(
        (e) => !e.guardian && !e.totem && (e.x <= -180 || e.x >= width + 180),
      );
    }
  }

  void _spawnFormation() {
    if (stage.area < 3 || totemChoices.isNotEmpty) return;
    final outstanding = _targetPool();
    final pool = _localAnimalPool();
    if (pool.isEmpty) return;
    final spec = (outstanding.isNotEmpty && _rng.nextDouble() < 0.58)
        ? ANIMAL_BY_ID[_randomItem(outstanding)]!
        : _randomItem(pool);
    final width = renderer.w;
    final height = renderer.h;
    final count = 3 + math.min(2, (stage.area / 4).floor());
    final fromLeft = _rng.nextDouble() < 0.6;
    final direction = fromLeft ? 1 : -1;
    final baseY = _pickY(spec.zone);
    final fid = ++formationId;
    for (int i = 0; i < count; i++) {
      final e = _makeEntity(spec, false);
      final center = (count - 1) / 2;
      e.direction = direction;
      e.x = fromLeft ? -70 - i * 38 : width + 70 + i * 38;
      if (spec.zone == 'sky')
        e.baseY = baseY + (i - center).abs() * 15;
      else if (spec.zone == 'water')
        e.baseY = baseY + math.sin(i * 1.5) * 18;
      else
        e.baseY = math.min(height * 0.69, baseY + (i % 2) * 8);
      e.y = e.baseY;
      e.formationId = fid;
      e.formationLeader = i == 0;
      e.visualScale *= 0.88;
      e.rare = false;
      entities.add(e);
    }
    _effect(
      'formation_spawn',
      fromLeft ? width * 0.14 : width * 0.86,
      baseY - 35,
      'FORMASI',
      false,
      105,
    );
  }

  void _spawnWaveSpecial(Animal spec, int index, int tier) {
    final width = renderer.w;
    final e = _makeEntity(spec, false);
    e.direction = index % 2 == 0 ? 1 : -1;
    e.x = e.direction > 0 ? -85 - index * 28 : width + 85 + index * 28;
    e.baseY = _pickY('land');
    e.y = e.baseY;
    e.rare = _rng.nextDouble() < tuning.rareChance * 1.35;
    _applyWaveTraits(e, true);
    if (tier == 5) e.armorHits = math.max(2, tuning.eliteTapCount.round());
    entities.add(e);
  }

  void _advanceWave(int nextWave) {
    wave = nextWave;
    final width = renderer.w;
    final height = renderer.h;
    if (nextWave == 4 || nextWave == 5) {
      final roster = WAVE_ROSTERS[nextWave]!;
      for (final id in roster) {
        targets[id] = (targets[id] ?? 0) + 1;
        if (!targetIds.contains(id)) targetIds.add(id);
      }
      int idx = 0;
      for (final id in roster) {
        _spawnWaveSpecial(ANIMAL_BY_ID[id]!, idx, nextWave);
        idx++;
      }
      final msg = nextWave == 4
          ? 'GELOMBANG 4 - SERBUAN KILAT'
          : 'GELOMBANG 5 - ELITE MULTI-TAP';
      _effect(
        nextWave == 4 ? 'wave_four_arrival' : 'wave_five_arrival',
        width * 0.5,
        height * 0.5,
        msg,
        false,
        math.min(width, height) * 0.76,
      );
      _showToast(
        nextWave == 4
            ? 'Empat hewan kilat datang!'
            : 'Elite berlapis memasuki arena!',
      );
      audio.guardian(nextWave + 2);
    } else {
      _effect(
        'formation_spawn',
        width * 0.5,
        height * 0.5,
        'GELOMBANG $nextWave/5',
        false,
        120,
      );
      _showToast('Gelombang $nextWave dimulai');
    }
    _syncHud(force: true);
  }

  void _updateWaves() {
    final progress = elapsed / math.max(1, totalTime);
    int desired = 1;
    if (progress >= 0.7)
      desired = 5;
    else if (progress >= 0.52)
      desired = 4;
    else if (progress >= 0.36)
      desired = 3;
    else if (progress >= 0.18)
      desired = 2;
    if (targets.values.every((count) => count <= 0) && wave < 5) {
      desired = math.max(desired, wave + 1);
    }
    while (wave < desired) _advanceWave(wave + 1);
  }

  void _updateTotems(double dt) {
    if (!totemOffered && stage.area >= 4 && elapsed >= totalTime * 0.27)
      _spawnTotemChoice();
    if (totemChoices.isNotEmpty) {
      totemChoiceTime -= dt;
      if (totemChoiceTime <= 0) {
        entities.removeWhere((e) => e.totem);
        totemChoices = [];
      }
    }
    if (mutator != null) {
      mutatorTime -= dt;
      if (mutatorTime <= 0) mutator = null;
    }
  }

  void _updateFormations() {
    if (elapsed < formationEvent) return;
    _spawnFormation();
    formationEvent +=
        (math.max(5, 9.2 - stage.area * 0.34) + _rng.nextDouble() * 1.5) *
        tuning.formationGapScale;
  }

  void _updatePressure() {
    final timeStrain = 1 - math.max(0, time) / math.max(1, totalTime);
    final comboHeat = math.min(0.46, combo * 0.035);
    final areaHeat = (stage.area - 1) * 0.025;
    final waveHeat = math.max(0, wave - 3) * 0.16;
    pressure =
        (timeStrain * 0.34 + comboHeat + areaHeat + waveHeat) *
        tuning.pressureIntensity;
    pressure = pressure.clamp(0, 1);
  }

  void _updateGuardian() {
    if (guardianSpec == null || guardianSpawned || guardianDefeated) return;
    final remaining = targets.values.fold(0, (s, c) => s + math.max(0, c));
    if (elapsed >= totalTime * 0.4 || remaining <= stage.total * 0.38)
      _spawnGuardian();
  }

  void _updateChallenge() {
    final challenge = stage.challenge;
    final cycle = elapsed % 7;
    challengeActive = false;
    if (challenge == 'burrow')
      challengeActive = cycle > 4.8;
    else if (challenge == 'camouflage')
      challengeActive = cycle > 4.2;
    else if (challenge == 'sandstorm')
      challengeActive = cycle > 3.6;
    else if (challenge == 'tide')
      challengeActive = cycle > 3.4;
    else if (challenge == 'ambush')
      challengeActive = cycle > 5.1;
    else if (['bubble', 'heat', 'dark', 'snow'].contains(challenge))
      challengeActive = true;
    else if (challenge == 'lava')
      challengeActive = cycle > 4.3;
    else if (['portal', 'chaos'].contains(challenge))
      challengeActive = true;

    if (elapsed < challengeEvent) return;
    if (challenge == 'stampede') {
      for (int i = 0; i < 7; i++) _spawnAnimal(true);
      _showToast('Gelombang kawanan datang!');
      challengeEvent += 6.5;
    } else if (['reverse', 'moonshift'].contains(challenge)) {
      for (final e in entities) e.direction *= -1;
      _showToast(
        challenge == 'reverse' ? 'Semua balik arah!' : 'Arah bulan berubah!',
      );
      challengeEvent += challenge == 'reverse' ? 6 : 4.5;
    } else if (challenge == 'portal') {
      final width = renderer.w;
      for (final e in entities.take(5)) {
        e.x = width * (0.08 + _rng.nextDouble() * 0.84);
        e.baseY = _pickY(e.spec.zone);
        e.y = e.baseY;
      }
      _showToast('Portal memindahkan kawanan!');
      challengeEvent += 4.8;
    } else if (challenge == 'chaos') {
      int i = 0;
      for (final e in entities) {
        if (i % 2 == 0) e.direction *= -1;
        i++;
      }
      for (int i = 0; i < 6; i++) _spawnAnimal(true);
      _showToast('Chaos berganti pola!');
      challengeEvent += 4.2;
    } else {
      challengeEvent = double.infinity;
    }
  }

  @override
  void update(double dt) {
    if (!assetsReady) return;
    _syncRendererSize();
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    audio.tickMusic();
    for (final e in effects) e.age += dt;
    effects.removeWhere((e) {
      final long =
          e.type.startsWith('skill_') ||
          e.type.startsWith('totem_') ||
          e.type.startsWith('mutator_') ||
          e.type.startsWith('formation_') ||
          e.type.startsWith('rare_') ||
          e.type.startsWith('wave_');
      return e.age >= (long ? 0.72 : (e.label.isNotEmpty ? 0.62 : 0.38));
    });
    if (mode == 'idle') {
      _updateEntities(dt, now);
      return;
    }
    if (mode != 'playing' || paused) return;
    if (freezeTime > 0) {
      freezeTime = math.max(0, freezeTime - dt);
      _syncHud(force: true);
      return;
    }
    elapsed += dt;
    _updateWaves();
    _updateTotems(dt);
    _updateFormations();
    _updatePressure();
    _updateChallenge();
    _updateGuardian();
    _updateEntities(dt, now);
    time -= dt;
    comboAge += dt;
    if (comboAge > 3.2) combo = 0;
    spawnTimer -= dt;
    final maxEntities = math.min(
      34,
      5 + stage.area * 2 + (stageIndex * 0.25).floor() + (pressure * 6).floor(),
    );
    if (spawnTimer <= 0 && entities.length < maxEntities) {
      _spawnAnimal();
      final baseGap = math.max(
        0.18,
        1.28 - stage.area * 0.092 - stageIndex * 0.018,
      );
      spawnTimer =
          baseGap *
          tuning.spawnScale *
          (1 - pressure * 0.34) *
          (0.72 + _rng.nextDouble() * 0.56);
    }
    if (time <= 0) finishStage(false);
    if (_toastTimer > 0) {
      _toastTimer -= dt;
      if (_toastTimer <= 0) {
        controller.toastVisible = false;
        controller.notify();
      }
    }
    _syncHud();
  }

  @override
  void render(ui.Canvas canvas) {
    if (!assetsReady) return;
    _syncRendererSize();
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    renderer.render(
      canvas,
      RenderInput(
        stage: stage,
        entities: entities,
        effects: effects,
        mutator: mutator,
        freezeTime: freezeTime,
        paused: paused,
        challengeActive: challengeActive,
        radarLevel: radarLevel,
        targets: targets,
        now: now,
      ),
    );
  }
}
