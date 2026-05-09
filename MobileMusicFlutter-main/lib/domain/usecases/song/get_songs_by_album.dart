import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/repository/song/song.dart';
import 'package:dartz/dartz.dart';

class GetSongsByAlbumUseCase {
  final SongsRepository repository;
  GetSongsByAlbumUseCase(this.repository);

  Future<Either<String, List<SongEntity>>> call(String albumId) {
    return repository.getSongsByAlbum(albumId);
  }
}
//test ablum 11/7