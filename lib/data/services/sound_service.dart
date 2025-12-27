import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

/// A Riverpod provider that exposes an instance of [SoundService].
///
/// This allows other parts of the application to easily access and use the service
/// for playing various sound effects.
final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

/// A service class responsible for playing various sound effects within the application.
///
/// It utilizes dedicated `AudioPlayer` instances for different sound types to ensure
/// low-latency playback and prevent delays in UI feedback. This eliminates the need
/// to call `stop()` before `play()`, which was a common cause of latency.
class SoundService {
  /// A private flag indicating whether sound effects are currently enabled.
  bool _isEnabled = true;

  // Dedicated players for each sound type - eliminates stop() latency
  /// Audio player for click sound effects.
  final AudioPlayer _clickPlayer = AudioPlayer();
  /// Audio player for success sound effects.
  final AudioPlayer _successPlayer = AudioPlayer();
  /// Audio player for delete sound effects.
  final AudioPlayer _deletePlayer = AudioPlayer();
  /// Audio player for money-in sound effects.
  final AudioPlayer _moneyInPlayer = AudioPlayer();
  /// Audio player for refresh sound effects.
  final AudioPlayer _refreshPlayer = AudioPlayer();
  /// Audio player for notification sound effects.
  final AudioPlayer _notificationPlayer = AudioPlayer();
  /// Audio player for application startup sound effects.
  final AudioPlayer _startupPlayer = AudioPlayer();

  /// Constructs a [SoundService] and configures all internal audio players.
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

  /// Configures an individual `AudioPlayer` for low-latency playback.
  ///
  /// - Parameters:
  ///   - `player`: The `AudioPlayer` instance to configure.
  void _configurePlayer(AudioPlayer player) {
    player.setReleaseMode(ReleaseMode.stop);
    player.setPlayerMode(PlayerMode.lowLatency);
  }

  /// Sets the enabled state of sound effects.
  ///
  /// - Parameters:
  ///   - `enabled`: A boolean value where `true` enables sound effects
  ///     and `false` disables them.
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Plays a click sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playClick() async {
    if (!_isEnabled) return;
    _playOnPlayer(_clickPlayer, 'audio/screen-tap-38717.mp3');
  }

  /// Plays a success sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playSuccess() async {
    if (!_isEnabled) return;
    _playOnPlayer(_successPlayer, 'audio/success_chime.mp3');
  }

  /// Plays a delete sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playDelete() async {
    if (!_isEnabled) return;
    _playOnPlayer(_deletePlayer, 'audio/delete_pop.mp3');
  }

  /// Plays a money-in sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playMoneyIn() async {
    if (!_isEnabled) return;
    _playOnPlayer(_moneyInPlayer, 'audio/register-cha-ching-376896.mp3');
  }

  /// Plays a refresh sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playRefresh() async {
    if (!_isEnabled) return;
    _playOnPlayer(_refreshPlayer, 'audio/refresh.mp3');
  }

  /// Plays a notification sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playNotification() async {
    if (!_isEnabled) return;
    _playOnPlayer(_notificationPlayer, 'audio/notification.mp3');
  }

  /// Plays a startup sound effect.
  ///
  /// This method will only play the sound if sound effects are currently enabled.
  /// - Returns: A `Future<void>` that completes when the sound playback is initiated.
  Future<void> playStartup() async {
    if (!_isEnabled) return;
    _playOnPlayer(_startupPlayer, 'audio/startup.mp3');
  }

  /// Plays a sound on a specific [AudioPlayer] instance from an asset path.
  ///
  /// This method uses a fire-and-forget pattern for UI sounds to minimize latency.
  /// It attempts to stop the player first to reset its state, then plays the new sound.
  /// Errors during playback (e.g., asset not found) are caught and ignored to prevent app crashes.
  ///
  /// - Parameters:
  ///   - `player`: The dedicated `AudioPlayer` instance to use.
  ///   - `assetPath`: The path to the audio asset to play.
  void _playOnPlayer(AudioPlayer player, String assetPath) {
    // Stop first to reset player state and prevent it from getting stuck
    player.stop().then((_) {
      player.play(AssetSource(assetPath)).catchError((_) {
        // Ignore errors (e.g. asset not found) to not crash app
      });
    }).catchError((_) {
      // If stop fails, try playing anyway
      player.play(AssetSource(assetPath)).catchError((_) {});
    });
  }

  /// Disposes of all internal `AudioPlayer` instances.
  ///
  /// This method should be called when the [SoundService] is no longer needed
  /// (e.g., when the application is closing) to release resources.
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

