import 'package:dartz/dartz.dart';
import 'package:music_player/domain/entities/album/album.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/data/sources/song/song_firebase_service.dart';

class GetAlbumsUseCase {
  // lay ablum
  final SongFirebaseService service;
  GetAlbumsUseCase(this.service);

  Future<Either<String, List<AlbumEntity>>> call({int limit = 10}) =>
      service.getAllAlbums(limit: limit);
}

class GetSongsByArtistUseCase {
  // lay bai hat theo artist
  final SongFirebaseService service;
  GetSongsByArtistUseCase(this.service);
  Future<Either<String, List<SongEntity>>> call(String artistName) =>
      service.getSongsByArtist(artistName);
}
