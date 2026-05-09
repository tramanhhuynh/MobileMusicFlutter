import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'dart:async';
import 'package:music_player/presentation/song_player/bloc/song_player_state.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  SongEntity? currentSongEntity;

  List<SongEntity> _songList = [];
  int _currentIndex = 0;

  // Thêm biến để lưu trạng thái phát nhạc
  bool _wasPlayingBeforePageChange = false;
  Duration _savedPosition = Duration.zero;

  // Thêm biến để lưu trữ danh sách bài hát gốc
  List<SongEntity> _originalSongList = [];
  int _originalCurrentIndex = 0;
  bool _isOriginalListActive = false;

  // Getter methods để truy cập từ bên ngoài
  List<SongEntity> get songList => _songList;
  int get currentIndex => _currentIndex;

  late StreamSubscription<Duration?> _positionSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    _initAudioPlayerListeners();
  }

  void _initAudioPlayerListeners() {
    _positionSubscription = audioPlayer.positionStream.listen((position) {
      if (state is SongPlayerLoaded) {
        emit((state as SongPlayerLoaded).copyWith(songPosition: position));
      }
    });

    _durationSubscription = audioPlayer.durationStream.listen((duration) {
      if (state is SongPlayerLoaded && duration != null) {
        emit((state as SongPlayerLoaded).copyWith(songDuration: duration));
      } else if (state is SongPlayerLoading && duration != null) {
        emit(
          SongPlayerLoaded(
            songDuration: duration,
            songPosition: audioPlayer.position,
            isPlaying: audioPlayer.playing,
            isLooping: false,
            isShuffling: false,
          ),
        );
      }
    });

    _playerStateSubscription = audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      if (state is SongPlayerLoaded) {
        emit(
          (state as SongPlayerLoaded).copyWith(isPlaying: playerState.playing),
        );
      }
      if (playerState.processingState == ProcessingState.completed) {
        // Khi hết bài, phát bài tiếp theo (có xét shuffle)
        // Chỉ phát bài tiếp theo nếu có danh sách bài hát
        if (_songList.isNotEmpty && _songList.length > 1) {
          print('🎵 Song completed, playing next song...');
          nextSong(isAlbum: true);
        } else {
          print('🎵 Song completed, no more songs in list');
        }
      }
    });
  }

  // Thêm method để lưu trạng thái khi chuyển trang
  void savePlaybackState() {
    if (state is SongPlayerLoaded) {
      _wasPlayingBeforePageChange = audioPlayer.playing;
      _savedPosition = audioPlayer.position;
      print(
        '🎵 Saved playback state - wasPlaying: $_wasPlayingBeforePageChange, position: $_savedPosition',
      );
    }
  }

  // Thêm method để khôi phục trạng thái khi quay lại
  void restorePlaybackState() {
    if (state is SongPlayerLoaded && _wasPlayingBeforePageChange) {
      // Khôi phục vị trí phát
      if (_savedPosition > Duration.zero) {
        audioPlayer.seek(_savedPosition);
      }

      // Khôi phục trạng thái phát nếu đang phát trước đó
      if (_wasPlayingBeforePageChange && !audioPlayer.playing) {
        audioPlayer.play();
      }

      print(
        '🎵 Restored playback state - wasPlaying: $_wasPlayingBeforePageChange, position: $_savedPosition',
      );
    }
  }

  void toggleLooping() {
    if (state is SongPlayerLoaded) {
      final current = state as SongPlayerLoaded;
      final newLooping = !current.isLooping;
      audioPlayer.setLoopMode(newLooping ? LoopMode.one : LoopMode.off);
      if (!isClosed) {
        emit(current.copyWith(isLooping: newLooping));
      }
    }
  }

  Future<void> loadSong(
    String url, {
    SongEntity? songEntity,
    bool showLoading = true,
  }) async {
    if (showLoading && !isClosed) emit(SongPlayerLoading());
    try {
      // Lưu thông tin bài hát hiện tại
      if (songEntity != null) {
        currentSongEntity = songEntity;
      }

      // Tạo MediaItem cho notification
      final mediaItem = MediaItem(
        id: songEntity?.songId ?? 'unknown',
        album:
            songEntity?.artist ??
            'Unknown Album', // Sử dụng artist thay vì album
        title: songEntity?.title ?? 'Unknown Title',
        artist: songEntity?.artist ?? 'Unknown Artist',
        artUri: Uri.parse(
          '${AppUrls.coverfirestorage}${songEntity?.artist ?? ''} - ${songEntity?.title ?? ''}.jpg?${AppUrls.mediaAlt}',
        ),
      );

      // Set audio source với MediaItem
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(url), tag: mediaItem),
      );

      final loadedState =
          state is SongPlayerLoaded ? state as SongPlayerLoaded : null;
      final isLooping = loadedState?.isLooping ?? false;
      final isShuffling = loadedState?.isShuffling ?? false;
      audioPlayer.setLoopMode(isLooping ? LoopMode.one : LoopMode.off);

      if (!isClosed) {
        emit(
          SongPlayerLoaded(
            songDuration: audioPlayer.duration ?? Duration.zero,
            songPosition: audioPlayer.position,
            isPlaying: audioPlayer.playing,
            isLooping: isLooping,
            isShuffling: isShuffling,
          ),
        );
      }

      // Chỉ play nếu chưa đang phát
      if (!audioPlayer.playing) {
        await audioPlayer.play();
      }
    } catch (e) {
      print('Lỗi khi tải bài hát: $e');
      if (!isClosed) {
        emit(SongPlayerFailure(message: 'Không thể tải bài hát: $e'));
      }
    }
  }

  void playOrPauseSong() {
    if (state is SongPlayerLoaded) {
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    }
  }

  void seekSong(Duration position) {
    if (state is SongPlayerLoaded) {
      audioPlayer.seek(position);
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void setSongList(List<SongEntity> list, int index) {
    _songList = list;
    _currentIndex = index;

    // Lưu trữ danh sách bài hát gốc nếu đây là lần đầu tiên hoặc danh sách mới khác với danh sách gốc
    if (_originalSongList.isEmpty ||
        !_isSameSongList(_originalSongList, list)) {
      _originalSongList = List.from(list);
      _originalCurrentIndex = index;
      _isOriginalListActive = true;
      print('🎵 Original playlist saved: ${_originalSongList.length} songs');
    }

    // Log thứ tự bài hát để kiểm tra
    print('=== SONG LIST ORDER DEBUG ===');
    print('Total songs: ${_songList.length}');
    print('Current index: $_currentIndex');
    print('Original list active: $_isOriginalListActive');
    for (int i = 0; i < _songList.length; i++) {
      print('[$i] ${_songList[i].title} - ${_songList[i].artist}');
    }
    print(
      'Current song: ${_songList.isNotEmpty ? _songList[_currentIndex].title : "None"}',
    );
    print('=============================');

    // Chỉ load bài hát mới nếu bài hát hiện tại khác với bài hát trong list
    if (_songList.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < _songList.length) {
      final newSong = _songList[_currentIndex];
      final currentSong = currentSongEntity;

      // Kiểm tra xem có phải cùng một bài hát không
      if (currentSong == null ||
          currentSong.songId != newSong.songId ||
          currentSong.title != newSong.title ||
          currentSong.artist != newSong.artist) {
        // Nếu khác bài hát, load bài hát mới
        loadSongByIndex(_currentIndex, showLoading: true);
      } else {
        // Nếu cùng bài hát, chỉ cập nhật currentSongEntity và song list mà không load lại
        currentSongEntity = newSong;
        print(
          'Same song detected, keeping current position and playback state',
        );

        // Đảm bảo state được emit với thông tin hiện tại
        if (state is SongPlayerLoaded) {
          final currentState = state as SongPlayerLoaded;
          if (!isClosed) {
            emit(
              currentState.copyWith(),
            ); // Emit lại state hiện tại để trigger rebuild
          }
        }
      }
    }
  }

  // Thêm method để so sánh hai danh sách bài hát
  bool _isSameSongList(List<SongEntity> list1, List<SongEntity> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].songId != list2[i].songId ||
          list1[i].title != list2[i].title ||
          list1[i].artist != list2[i].artist) {
        return false;
      }
    }
    return true;
  }

  void loadSongByIndex(int index, {bool showLoading = false}) {
    if (_songList.isEmpty) return;
    _currentIndex = index;
    final song = _songList[_currentIndex];

    // Kiểm tra xem có phải cùng bài hát không
    if (currentSongEntity != null &&
        currentSongEntity!.songId == song.songId &&
        currentSongEntity!.title == song.title &&
        currentSongEntity!.artist == song.artist) {
      print('Same song in loadSongByIndex, skipping reload');
      return;
    }

    currentSongEntity = song;
    final fileName = Uri.encodeComponent(
      'songs/${song.artist} - ${song.title}.mp3',
    );
    final url =
        'https://firebasestorage.googleapis.com/v0/b/login-f7994.appspot.com/o/$fileName?alt=media';
    loadSong(url, songEntity: song, showLoading: showLoading);
  }

  void nextSong({bool isAlbum = false}) {
    // Sử dụng danh sách bài hát gốc nếu có và đang active
    List<SongEntity> songListToUse =
        _isOriginalListActive && _originalSongList.isNotEmpty
            ? _originalSongList
            : _songList;
    int currentIndexToUse =
        _isOriginalListActive && _originalSongList.isNotEmpty
            ? _originalCurrentIndex
            : _currentIndex;

    if (songListToUse.isEmpty) return;
    int nextIndex = currentIndexToUse;
    final loadedState =
        state is SongPlayerLoaded ? state as SongPlayerLoaded : null;
    final isShuffling = loadedState?.isShuffling ?? false;
    if (songListToUse.length > 1) {
      if (!isShuffling) {
        // Không shuffle: phát theo thứ tự
        nextIndex = (currentIndexToUse + 1) % songListToUse.length;
      } else {
        // Shuffle mode: chọn random bài khác
        final candidates = List.generate(songListToUse.length, (i) => i)
          ..remove(currentIndexToUse);
        candidates.shuffle();
        nextIndex = candidates.first;
      }
    } else {
      // Nếu chỉ có 1 bài hát, không làm gì
      print('🎵 Only one song in list, staying on current song');
      return;
    }

    // Log thông tin skip
    print('=== NEXT SONG DEBUG ===');
    print(
      'Using original list: ${_isOriginalListActive && _originalSongList.isNotEmpty}',
    );
    print('Current index: $currentIndexToUse');
    print('Next index: $nextIndex');
    print('Is album: $isAlbum');
    print('Is shuffling: $isShuffling');
    print(
      'Next song: ${songListToUse[nextIndex].title} - ${songListToUse[nextIndex].artist}',
    );
    print('======================');

    // Cập nhật index và load bài hát
    if (_isOriginalListActive && _originalSongList.isNotEmpty) {
      _originalCurrentIndex = nextIndex;
      _loadSongFromOriginalList(nextIndex, showLoading: false);
    } else {
      _currentIndex = nextIndex;
      loadSongByIndex(nextIndex, showLoading: false);
    }
  }

  void prevSong({bool isAlbum = false}) {
    // Sử dụng danh sách bài hát gốc nếu có và đang active
    List<SongEntity> songListToUse =
        _isOriginalListActive && _originalSongList.isNotEmpty
            ? _originalSongList
            : _songList;
    int currentIndexToUse =
        _isOriginalListActive && _originalSongList.isNotEmpty
            ? _originalCurrentIndex
            : _currentIndex;

    if (songListToUse.isEmpty) return;
    int prevIndex = currentIndexToUse;
    final loadedState =
        state is SongPlayerLoaded ? state as SongPlayerLoaded : null;
    final isShuffling = loadedState?.isShuffling ?? false;
    if (songListToUse.length > 1) {
      if (!isShuffling) {
        // Không shuffle: phát theo thứ tự
        prevIndex =
            (currentIndexToUse - 1 + songListToUse.length) %
            songListToUse.length;
      } else {
        // Shuffle mode: chọn random bài khác
        final candidates = List.generate(songListToUse.length, (i) => i)
          ..remove(currentIndexToUse);
        candidates.shuffle();
        prevIndex = candidates.first;
      }
    } else {
      // Nếu chỉ có 1 bài hát, không làm gì
      print('🎵 Only one song in list, staying on current song');
      return;
    }

    // Log thông tin previous
    print('=== PREVIOUS SONG DEBUG ===');
    print(
      'Using original list: ${_isOriginalListActive && _originalSongList.isNotEmpty}',
    );
    print('Current index: $currentIndexToUse');
    print('Previous index: $prevIndex');
    print('Is album: $isAlbum');
    print('Is shuffling: $isShuffling');
    print(
      'Previous song: ${songListToUse[prevIndex].title} - ${songListToUse[prevIndex].artist}',
    );
    print('==========================');

    // Cập nhật index và load bài hát
    if (_isOriginalListActive && _originalSongList.isNotEmpty) {
      _originalCurrentIndex = prevIndex;
      _loadSongFromOriginalList(prevIndex, showLoading: false);
    } else {
      _currentIndex = prevIndex;
      loadSongByIndex(prevIndex, showLoading: false);
    }
  }

  // Thêm method để đảm bảo trạng thái phát nhạc được duy trì
  void ensurePlaybackContinuity() {
    // Sử dụng danh sách bài hát gốc nếu có và đang active
    List<SongEntity> songListToUse =
        _isOriginalListActive && _originalSongList.isNotEmpty
            ? _originalSongList
            : _songList;

    if (state is SongPlayerLoaded && songListToUse.isNotEmpty) {
      // Đảm bảo rằng nếu đang phát và hết bài, sẽ chuyển sang bài tiếp theo
      final duration = audioPlayer.duration;
      if (audioPlayer.playing &&
          duration != null &&
          audioPlayer.position >= duration) {
        print('🎵 Ensuring playback continuity - song ended, playing next');
        nextSong(isAlbum: true);
      }
    }
  }

  void toggleShuffling() {
    if (state is SongPlayerLoaded) {
      final current = state as SongPlayerLoaded;
      final newShuffling = !current.isShuffling;
      if (!isClosed) {
        emit(current.copyWith(isShuffling: newShuffling));
      }
    }
  }

  // Thêm method để load bài hát từ danh sách gốc
  void _loadSongFromOriginalList(int index, {bool showLoading = false}) {
    if (_originalSongList.isEmpty) return;
    final song = _originalSongList[index];

    // Kiểm tra xem có phải cùng một bài hát không
    if (currentSongEntity != null &&
        currentSongEntity!.songId == song.songId &&
        currentSongEntity!.title == song.title &&
        currentSongEntity!.artist == song.artist) {
      print('Same song in _loadSongFromOriginalList, skipping reload');
      return;
    }

    currentSongEntity = song;
    final fileName = Uri.encodeComponent(
      'songs/${song.artist} - ${song.title}.mp3',
    );
    final url =
        'https://firebasestorage.googleapis.com/v0/b/login-f7994.appspot.com/o/$fileName?alt=media';
    loadSong(url, songEntity: song, showLoading: showLoading);
  }

  // Thêm method để reset danh sách bài hát gốc
  void resetOriginalPlaylist() {
    _originalSongList.clear();
    _originalCurrentIndex = 0;
    _isOriginalListActive = false;
    print('🎵 Original playlist reset');
  }

  // Thêm method để kiểm tra xem có đang sử dụng danh sách gốc không
  bool get isUsingOriginalPlaylist =>
      _isOriginalListActive && _originalSongList.isNotEmpty;

  // Thêm method để lấy danh sách bài hát hiện tại đang sử dụng
  List<SongEntity> get currentSongList {
    return _isOriginalListActive && _originalSongList.isNotEmpty
        ? _originalSongList
        : _songList;
  }

  // Thêm method để lấy index hiện tại
  int get currentSongIndex {
    return _isOriginalListActive && _originalSongList.isNotEmpty
        ? _originalCurrentIndex
        : _currentIndex;
  }

  // Thêm method để debug thông tin playlist
  void debugPlaylistInfo() {
    print('=== PLAYLIST DEBUG INFO ===');
    print('Original list active: $_isOriginalListActive');
    print('Original list length: ${_originalSongList.length}');
    print('Original current index: $_originalCurrentIndex');
    print('Current list length: ${_songList.length}');
    print('Current index: $_currentIndex');
    print('Current song: ${currentSongEntity?.title ?? "None"}');
    if (_originalSongList.isNotEmpty) {
      print('Original playlist songs:');
      for (int i = 0; i < _originalSongList.length; i++) {
        print(
          '  [$i] ${_originalSongList[i].title} - ${_originalSongList[i].artist}',
        );
      }
    }
    print('==========================');
  }

  @override
  Future<void> close() {
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _playerStateSubscription.cancel();

    if (audioPlayer.playing) {
      audioPlayer.stop();
    }
    audioPlayer.dispose();

    return super.close();
  }
}
