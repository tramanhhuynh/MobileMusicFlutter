import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/domain/repository/playlist/playlist.dart';
import 'package:music_player/service_locator.dart';

class DeletePlaylistUseCase implements UseCase<Either<String, void>, String> {
  @override
  Future<Either<String, void>> call({String? params}) async {
    if (params == null) {
      return Left('Thiếu playlistId');
    }
    return await sl<PlaylistRepository>().deletePlaylist(params);
  }
} 