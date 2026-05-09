abstract class SongPlayerState {}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final Duration songDuration;
  final Duration songPosition;
  final bool isPlaying;
  final bool isLooping;
  final bool isShuffling;

  SongPlayerLoaded({
    required this.songDuration,
    required this.songPosition,
    required this.isPlaying,
    this.isLooping = false,
    this.isShuffling = false,
  });

  SongPlayerLoaded copyWith({
    Duration? songDuration,
    Duration? songPosition,
    bool? isPlaying,
    bool? isLooping,
    bool? isShuffling,
  }) {
    return SongPlayerLoaded(
      songDuration: songDuration ?? this.songDuration,
      songPosition: songPosition ?? this.songPosition,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isShuffling: isShuffling ?? this.isShuffling,
    );
  }
}

class SongPlayerFailure extends SongPlayerState {
  final String message;

  SongPlayerFailure({
    this.message = 'Không thể tải bài hát. Vui lòng thử lại.',
  });
}
