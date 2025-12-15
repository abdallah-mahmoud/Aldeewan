import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

/// Sound service with dedicated players per sound type for low-latency playback.
/// 
/// Using separate AudioPlayer instances eliminates the need to stop() before
/// playing, which was causing noticeable delay in UI feedback.
class SoundService {
  bool _isEnabled = true;

  // Dedicated players for each sound type - eliminates stop() latency
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _deletePlayer = AudioPlayer();
  final AudioPlayer _moneyInPlayer = AudioPlayer();
  final AudioPlayer _refreshPlayer = AudioPlayer();
  final AudioPlayer _notificationPlayer = AudioPlayer();
  final AudioPlayer _startupPlayer = AudioPlayer();

  SoundService() {
    // Configure all players for low latency
    _configurePlayer(_clickPlayer);
    _configurePlayer(_successPlayer);
    _configurePlayer(_deletePlayer);
    _configurePlayer(_moneyInPlayer);
    _configurePlayer(_refreshPlayer);
    _configurePlayer(_notificationPlayer);
    _configurePlayer(_startupPlayer);
  }

  void _configurePlayer(AudioPlayer player) {
    player.setReleaseMode(ReleaseMode.stop);
    player.setPlayerMode(PlayerMode.lowLatency);
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> playClick() async {
    if (!_isEnabled) return;
    _playOnPlayer(_clickPlayer, 'audio/screen-tap-38717.mp3');
  }

  Future<void> playSuccess() async {
    if (!_isEnabled) return;
    _playOnPlayer(_successPlayer, 'audio/success_chime.mp3');
  }

  Future<void> playDelete() async {
    if (!_isEnabled) return;
    _playOnPlayer(_deletePlayer, 'audio/delete_pop.mp3');
  }

  Future<void> playMoneyIn() async {
    if (!_isEnabled) return;
    _playOnPlayer(_moneyInPlayer, 'audio/register-cha-ching-376896.mp3');
  }

  Future<void> playRefresh() async {
    if (!_isEnabled) return;
    _playOnPlayer(_refreshPlayer, 'audio/refresh.mp3');
  }

  Future<void> playNotification() async {
    if (!_isEnabled) return;
    _playOnPlayer(_notificationPlayer, 'audio/notification.mp3');
  }

  Future<void> playStartup() async {
    if (!_isEnabled) return;
    _playOnPlayer(_startupPlayer, 'audio/startup.mp3');
  }

  /// Play sound on dedicated player without awaiting to minimize latency.
  /// Fire-and-forget pattern for UI sounds.
  void _playOnPlayer(AudioPlayer player, String assetPath) {
    // Don't await - fire and forget for minimal latency
    player.play(AssetSource(assetPath)).catchError((_) {
      // Ignore errors (e.g. asset not found) to not crash app
    });
  }

  /// Dispose all players when service is no longer needed.
  void dispose() {
    _clickPlayer.dispose();
    _successPlayer.dispose();
    _deletePlayer.dispose();
    _moneyInPlayer.dispose();
    _refreshPlayer.dispose();
    _notificationPlayer.dispose();
    _startupPlayer.dispose();
  }
}

