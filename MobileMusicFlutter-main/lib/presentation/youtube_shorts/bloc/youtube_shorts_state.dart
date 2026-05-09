import 'package:equatable/equatable.dart';
import 'package:music_player/data/sources/youtube/youtube_shorts_service.dart';

abstract class YouTubeShortsState extends Equatable {
  const YouTubeShortsState();

  @override
  List<Object?> get props => [];
}

class YouTubeShortsInitial extends YouTubeShortsState {}

class YouTubeShortsLoading extends YouTubeShortsState {}

class YouTubeShortsLoaded extends YouTubeShortsState {
  final List<YouTubeShortsVideo> videos;
  final bool hasReachedMax;

  const YouTubeShortsLoaded({
    required this.videos,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [videos, hasReachedMax];

  YouTubeShortsLoaded copyWith({
    List<YouTubeShortsVideo>? videos,
    bool? hasReachedMax,
  }) {
    return YouTubeShortsLoaded(
      videos: videos ?? this.videos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class YouTubeShortsError extends YouTubeShortsState {
  final String message;

  const YouTubeShortsError(this.message);

  @override
  List<Object?> get props => [message];
} 