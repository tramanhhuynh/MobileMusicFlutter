import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/repository/playlist/playlist.dart';
import 'package:music_player/service_locator.dart';

class CreatePlaylistUseCase implements UseCase<Either<String, PlaylistEntity>, String> {
  @override
  Future<Either<String, PlaylistEntity>> call({String? params}) async {
    return await sl<PlaylistRepository>().createPlaylist(params ?? '');
  }
} 