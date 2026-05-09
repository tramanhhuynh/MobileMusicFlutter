import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/domain/repository/song/song.dart'; // dùng interface
import 'package:music_player/service_locator.dart';

class IsFavoriteSongUseCase implements UseCase<bool, String> {
  @override
  Future<bool> call({String ? params}) async {
    return await sl<SongsRepository>().isFavoriteSong(params!);
  }
}
