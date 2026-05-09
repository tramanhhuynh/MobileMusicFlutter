import 'package:music_player/domain/entities/playlist/playlist.dart';

enum LibraryFilter { all, music, album }

class LibState {}

class LibraryLoading extends LibState {}

class LibraryLoaded extends LibState {
  final List<dynamic> recentItems; // Có thể là SongEntity, ArtistEntity, ...
  final List<PlaylistEntity> playlists;
  final LibraryFilter filter;

  LibraryLoaded({
    required this.recentItems, 
    required this.playlists,
    required this.filter,
  });

  LibraryLoaded copyWith({
    List<dynamic>? recentItems,
    List<PlaylistEntity>? playlists,
    LibraryFilter? filter,
  }) {
    return LibraryLoaded(
      recentItems: recentItems ?? this.recentItems,
      playlists: playlists ?? this.playlists,
      filter: filter ?? this.filter,
    );
  }
}