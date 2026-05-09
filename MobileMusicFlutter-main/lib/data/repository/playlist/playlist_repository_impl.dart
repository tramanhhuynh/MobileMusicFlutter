import 'package:dartz/dartz.dart';
import 'package:music_player/data/sources/playlist/playlist_firebase_service.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/repository/playlist/playlist.dart';

class PlaylistRepositoryImpl extends PlaylistRepository {
  final PlaylistFirebaseService _playlistService;

  PlaylistRepositoryImpl(this._playlistService);

  @override
  Future<Either<String, List<PlaylistEntity>>> getUserPlaylists() async {
    return await _playlistService.getUserPlaylists();
  }

  @override
  Future<Either<String, PlaylistEntity>> createPlaylist(String name) async {
    return await _playlistService.createPlaylist(name);
  }

  @override
  Future<Either<String, PlaylistEntity>> addSongToPlaylist(String playlistId, String songId) async {
    return await _playlistService.addSongToPlaylist(playlistId, songId);
  }

  @override
  Future<Either<String, PlaylistEntity>> removeSongFromPlaylist(String playlistId, String songId) async {
    return await _playlistService.removeSongFromPlaylist(playlistId, songId);
  }

  @override
  Future<Either<String, void>> deletePlaylist(String playlistId) async {
    return await _playlistService.deletePlaylist(playlistId);
  }
} 