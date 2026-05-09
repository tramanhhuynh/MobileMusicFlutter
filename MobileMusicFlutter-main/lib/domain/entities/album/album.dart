import 'package:music_player/domain/entities/song/song.dart';

class AlbumEntity {
  final String id;
  final String albumName;
  final String artist;
  final DateTime releaseDate;
  final String? coverUrl;
  final String? type;

  AlbumEntity({
    required this.id,
    required this.albumName,
    required this.artist,
    required this.releaseDate,
    this.coverUrl,
    this.type,
  });
}
