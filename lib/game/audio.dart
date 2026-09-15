import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

/// Asset-backed SFX and looping background music for the game.
/// SFX use a small pool of players and BGM uses its own player, so they
/// play together instead of interrupting each other.
class AudioBus {
  // Flip to false to silence diagnostics once everything works.
  static bool debug = true;

  static void _log(String msg) {
    if (debug) print('[AudioBus] $msg');
  }

  AudioBus() {
    final context = _audioContext();
    unawaited(AudioPlayer.global.setAudioContext(context));
    unawaited(_bgm.setAudioContext(context));
    // Configure the looping BGM player once. Avoid stop()/seek right before
    // play() — on Android that throws MEDIA_ERROR_UNKNOWN (what:-38).
    unawaited(_bgm.setReleaseMode(ReleaseMode.loop));
    unawaited(_bgm.setVolume(0.5));
    for (var i = 0; i < _poolSize; i++) {
      final player = AudioPlayer(playerId: 'sfx_$i');
      unawaited(player.setAudioContext(context));
      _players.add(player);
    }
  }

  static const int _poolSize = 6;
  static const int _bgmCount = 5;

  final List<AudioPlayer> _players = [];
  final AudioPlayer _bgm = AudioPlayer(playerId: 'safari_bgm');
  int _poolIndex = 0;
  int _bgmTrack = 1;
  bool _bgmPlaying = false;
  bool _unlocked = false;
  bool _disposed = false;

  AudioContext _audioContext() => AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const [AVAudioSessionOptions.mixWithOthers],
        ),
      );

  void _play(String name, {double volume = 0.75, double pitch = 1}) {
    if (_disposed || !_unlocked || _players.isEmpty) {
      _log('sfx blocked: $name (disposed=$_disposed unlocked=$_unlocked)');
      return;
    }
    final player = _players[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _poolSize;
    unawaited(_playSafely(player, name, volume, pitch));
  }

  Future<void> _playSafely(
    AudioPlayer player,
    String name,
    double volume,
    double pitch,
  ) async {
    final asset = 'audio/$name.mp3';
    _log('play sfx: $asset (vol=$volume pitch=$pitch)');
    try {
      // stop() on an idle/preparing player can emit Android MEDIA_ERROR_UNKNOWN;
      // ignore it — play() will (re)start the source regardless.
      try {
        await player.stop();
      } catch (_) {}
      await player.setVolume(volume);
      await player.play(AssetSource(asset));
      if (pitch != 1) {
        try {
          await player.setPlaybackRate(pitch.clamp(0.7, 1.35));
        } catch (e) {
          _log('setPlaybackRate skipped: $e');
        }
      }
    } catch (e) {
      _log('ERROR playing $asset: $e');
    }
  }

  int _trackForLevel(int level) =>
      ((level.clamp(1, 20) - 1) ~/ 4) + 1;

  Future<void> _startBgm() async {
    if (_disposed || !_unlocked) {
      _log('BGM not started (disposed=$_disposed unlocked=$_unlocked)');
      return;
    }
    final asset = 'audio/bgm$_bgmTrack.mp3';
    _log('start BGM: $asset');
    try {
      // Don't call stop() first — on Android that raises MEDIA_ERROR_UNKNOWN
      // (what:-38) while the player is preparing. play() restarts cleanly.
      await _bgm.play(AssetSource(asset));
      _bgmPlaying = true;
      _log('BGM playing track $_bgmTrack');
    } catch (e) {
      _log('ERROR playing BGM $asset: $e');
      _bgmPlaying = false;
    }
  }

  void correct(int combo) =>
      _play('hit', volume: 0.75, pitch: math.min(1.35, 1 + combo * 0.04));
  void wrong() => _play('fail');
  void rare() => _play('rare');
  void clear() => _play('win');
  void guardian([int remaining = 1]) => _play('guardian');
  void totem() => _play('totem');

  void unlock() {
    if (_disposed) return;
    _unlocked = true;
    _log('unlocked, starting BGM');
    unawaited(_startBgm());
  }

  /// Switch the looping BGM to the track for the given 1-based level/area.
  /// 20 areas are split across 5 tracks (4 areas each):
  /// bgm1 (areas 1-4), bgm2 (5-8), bgm3 (9-12), bgm4 (13-16), bgm5 (17-20).
  void setLevelBgm(int level) {
    if (_disposed) return;
    final track = _trackForLevel(level).clamp(1, _bgmCount);
    if (track == _bgmTrack && _bgmPlaying) return;
    _bgmTrack = track;
    if (_unlocked) unawaited(_startBgm());
  }

  void tickMusic() {
    if (_unlocked && !_bgmPlaying) unawaited(_startBgm());
  }

  Future<void> destroy() async {
    _disposed = true;
    try {
      await _bgm.stop();
      await _bgm.dispose();
    } catch (_) {}
    for (final player in _players) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}
