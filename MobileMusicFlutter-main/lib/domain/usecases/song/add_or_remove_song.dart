import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/domain/repository/song/song.dart'; // dùng interface
import 'package:music_player/service_locator.dart';

class AddOrRemoveFavoriteSongUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String ? params}) async {
    return await sl<SongsRepository>().addOrRemoveFavoriteSongs(params!);
  }
}
