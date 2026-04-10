import 'package:audioplayers/audioplayers.dart';
import 'package:logging/logging.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final Logger _logger = Logger('SoundManager');
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  bool _initialized = false;

  static const _clickSound = 'click.wav';
  static const _clearSound = 'clear.wav';
  static const _equalsSound = 'equals.wav';
  static const _errorSound = 'error.wav';

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Preload click sound to check availability
      await _player.setSource(AssetSource('sounds/$_clickSound'));
      _initialized = true;
    } catch (e) {
      _logger.warning('Sound assets not found. Sound disabled.');
      _enabled = false;
      _initialized = true;
    }
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> _play(String asset) async {
    if (!_enabled) return;
    if (!_initialized) await initialize();
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/$asset'));
    } catch (e) {
      // Silently ignore missing sound files
      _enabled = false;
    }
  }

  Future<void> playClick() => _play(_clickSound);
  Future<void> playClear() => _play(_clearSound);
  Future<void> playEquals() => _play(_equalsSound);
  Future<void> playError() => _play(_errorSound);

  void dispose() {
    _player.dispose();
  }
}