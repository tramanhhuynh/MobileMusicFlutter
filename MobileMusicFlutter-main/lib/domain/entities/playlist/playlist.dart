import 'package:music_player/domain/entities/song/song.dart';

class PlaylistEntity {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final List<String> songIds;
  final List<SongEntity> songs;

  PlaylistEntity({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.songIds,
    required this.songs,
  });

  PlaylistEntity copyWith({
    String? id,
    String? name,
    String? userId,
    DateTime? createdAt,
    List<String>? songIds,
    List<SongEntity>? songs,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      songIds: songIds ?? this.songIds,
      songs: songs ?? this.songs,
    );
  }
} 