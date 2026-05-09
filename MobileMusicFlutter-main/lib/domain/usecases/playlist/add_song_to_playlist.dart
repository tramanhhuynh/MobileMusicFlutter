import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/repository/playlist/playlist.dart';
import 'package:music_player/service_locator.dart';

class AddSongToPlaylistUseCase implements UseCase<Either<String, PlaylistEntity>, Map<String, String>> {
  @override
  Future<Either<String, PlaylistEntity>> call({Map<String, String>? params}) async {
    if (params == null || !params.containsKey('playlistId') || !params.containsKey('songId')) {
      return Left('Thiếu thông tin playlistId hoặc songId');
    }
    return await sl<PlaylistRepository>().addSongToPlaylist(params['playlistId']!, params['songId']!);
  }
} 