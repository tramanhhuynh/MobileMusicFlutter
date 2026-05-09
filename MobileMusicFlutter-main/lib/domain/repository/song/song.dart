import 'package:dartz/dartz.dart';
import 'package:music_player/domain/entities/song/song.dart';

abstract class SongsRepository {
  Future<Either> getNewsSong();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSongs(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();
  Future<Either<String, List<SongEntity>>> getSongsByAlbum(String albumId);
}
