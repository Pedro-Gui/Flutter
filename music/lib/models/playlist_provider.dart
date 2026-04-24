import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:music/models/playlist_option.dart';
import 'package:music/models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [];
  final List<PlaylistOption> _options = [];
  int? currentSongIndex = 0;

  
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  List<Song> get playlist => _playlist;
  int? get getCurrentSongIndex => currentSongIndex;
  List<PlaylistOption> get options => _options;

  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;

  set currentSongIndeX(int? index) {
    if(index != null){
      currentSongIndex = index;
      play();
      notifyListeners();
    } 
  }

  PlaylistProvider() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    listenToDurations();
    loadPlaylistOptions();
  }

  void play() async {
    final String path = _playlist[currentSongIndex!].audioPath;
    
    _isPlaying = false; 
    notifyListeners();

    await _audioPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 50)); 
    
    await _audioPlayer.play(AssetSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() async {
    _isPlaying ? pause() : resume();
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playNextSong() async {
    if (currentSongIndex != null) {
      if (currentSongIndex! < _playlist.length - 1) {
        currentSongIndex = currentSongIndex! + 1;
        play();
      } else {
        currentSongIndex = 0;
        play();
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      if (currentSongIndex != null) {
        if (currentSongIndex! > 0) {
          currentSongIndex = currentSongIndex! - 1;
          play();
        } else {
          currentSongIndex = _playlist.length - 1;
          play();
        }
      }
    }
  }

  void listenToDurations() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {playNextSong();});
  }

  Future<void> loadPlaylistByName(String playlistName) async {
    _playlist.clear();

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final String formattedPathName = playlistName.trim().replaceAll(' ', '_');

      final List<String> audioPaths = manifest
          .listAssets()
          .where(
            (String key) =>
                key.startsWith('assets/audios/$formattedPathName/') &&
                key.endsWith('.mp3'),
          )
          .toList();
      audioPaths.sort();

      for (String path in audioPaths) {
        String fileName = path.split('/').last.replaceAll('.mp3', '');
        
        String finalPath = path.replaceFirst('assets/', '');

        _playlist.add(
          Song(
            songName: fileName,
            artistName: playlistName,
            albumArtImagePath: 'assets/images/$formattedPathName.jpg',
            audioPath: finalPath, 
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      print("Erro ao carregar playlist: $e");
    }
  }

  Future<void> loadPlaylistOptions() async {
    _options.clear();

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> audioPaths = manifest
          .listAssets()
          .where((String key) => key.startsWith('assets/audios/'))
          .toList();
      final Set<String> artistFolders = {};
      for (String path in audioPaths) {
        final parts = path.split('/');
        if (parts.length >= 4) {
          artistFolders.add(parts[2]);
        }
      }
      for (String folderName in artistFolders) {
        String formattedArtistName = folderName.replaceAll('_', ' ');
        _options.add(
          PlaylistOption(
            artistName: formattedArtistName,
            imagePath: 'assets/images/$folderName.jpg',
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      print("Erro ao carregar opções de playlist: $e");
    }
  }
}
