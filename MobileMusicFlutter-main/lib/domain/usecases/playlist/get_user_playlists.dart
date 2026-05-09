import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/repository/playlist/playlist.dart';
import 'package:music_player/service_locator.dart';

class GetUserPlaylistsUseCase implements UseCase<Either<String, List<PlaylistEntity>>, void> {
  @override
  Future<Either<String, List<PlaylistEntity>>> call({params}) async {
    return await sl<PlaylistRepository>().getUserPlaylists();
  }
} 