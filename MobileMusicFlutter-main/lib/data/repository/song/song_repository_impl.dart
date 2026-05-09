import 'package:dartz/dartz.dart';
import 'package:music_player/data/sources/song/song_firebase_service.dart';
import 'package:music_player/domain/repository/song/song.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/service_locator.dart';

class SongRepositoryImpl extends SongsRepository {
  @override
  Future<Either> getNewsSong() async {
    return await sl<SongFirebaseService>().getNewsSongs();
  }

  @override
  Future<Either> getPlayList() async {
    return await sl<SongFirebaseService>().getPlayList();
  }

  @override
  Future<Either> addOrRemoveFavoriteSongs(String songId) async {
    return await sl<SongFirebaseService>().addOrRemoveFavoriteSong(songId);
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    return await sl<SongFirebaseService>().isFavoriteSong(songId);
  }

  @override
  Future<Either> getUserFavoriteSongs() async {
    return await sl<SongFirebaseService>().getUserFavoriteSongs();
  }
  //Test cubit 11/7
  @override
  Future<Either<String, List<SongEntity>>> getSongsByAlbum(
    String albumId,
  ) async {
    return await sl<SongFirebaseService>().getSongsInAlbum(albumId);
  }

}
