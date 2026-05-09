import 'package:dartz/dartz.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';

abstract class PlaylistRepository {
  Future<Either<String, List<PlaylistEntity>>> getUserPlaylists();
  Future<Either<String, PlaylistEntity>> createPlaylist(String name);
  Future<Either<String, PlaylistEntity>> addSongToPlaylist(String playlistId, String songId);
  Future<Either<String, PlaylistEntity>> removeSongFromPlaylist(String playlistId, String songId);
  Future<Either<String, void>> deletePlaylist(String playlistId);
} 