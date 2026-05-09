import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/entities/song/song.dart';

class PlaylistModel {
  String? id;
  String? name;
  String? userId;
  Timestamp? createdAt;
  List<String>? songIds;
  List<SongEntity>? songs;

  PlaylistModel({
    this.id,
    this.name,
    this.userId,
    this.createdAt,
    this.songIds,
    this.songs,
  });

  PlaylistModel.fromJson(Map<String, dynamic> data) {
    name = data['name'];
    userId = data['userId'];
    createdAt = data['createdAt'];
    songIds = List<String>.from(data['songIds'] ?? []);
  }
}

extension PlaylistModelX on PlaylistModel {
  PlaylistEntity toEntity() {
    return PlaylistEntity(
      id: id ?? '',
      name: name ?? '',
      userId: userId ?? '',
      createdAt: createdAt?.toDate() ?? DateTime.now(),
      songIds: songIds ?? [],
      songs: songs ?? [],
    );
  }
} 