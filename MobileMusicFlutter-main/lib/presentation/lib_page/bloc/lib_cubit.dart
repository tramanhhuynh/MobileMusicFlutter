import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/usecases/song/get_news_songs.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/service_locator.dart';
import 'lib_state.dart';
import 'package:music_player/domain/entities/album/album.dart'; 
import 'package:music_player/domain/usecases/album/get_albums.dart';
import 'package:music_player/domain/usecases/playlist/get_user_playlists.dart';
import 'package:flutter/foundation.dart';

// Album State
abstract class AlbumState {}
class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {  final List<AlbumEntity> albums;
  AlbumLoaded(this.albums);
}

class AlbumError extends AlbumState {
  final String message;
  AlbumError(this.message);
}

// Album Cubit
class AlbumCubit extends Cubit<AlbumState> {
  final GetAlbumsUseCase getAlbumsUseCase;
  AlbumCubit(this.getAlbumsUseCase) : super(AlbumLoading());
//lay 10 album
  Future<void> fetchAlbums({int limit = 10}) async {
    if (!isClosed) emit(AlbumLoading());
    final result = await getAlbumsUseCase(limit: limit);
    result.fold(
      (error) {
        debugPrint('Album error: $error');
        if (!isClosed) emit(AlbumError(error));
      },
      (albums) {
        debugPrint('Album loaded: ${albums.length}');
        if (!isClosed) emit(AlbumLoaded(albums));
      },
    );
  }
}

class LibCubit extends Cubit<LibState> {
  final GetNewsSongsUseCase getNewsSongsUseCase;

  LibCubit(this.getNewsSongsUseCase) : super(LibraryLoading());

  Future<void> loadLibrary() async {
    print('=== LIB CUBIT LOAD LIBRARY ===');
    print('Loading library...');
    if (!isClosed) emit(LibraryLoading());
    
    // Load songs
    final songsResult = await getNewsSongsUseCase();
    List<SongEntity> songs = [];
    songsResult.fold(
      (failure) {
        debugPrint('Songs error: $failure');
      },
      (songsData) {
        songs = songsData as List<SongEntity>;
      },
    );

    // Load user playlists
    final playlistsResult = await sl<GetUserPlaylistsUseCase>().call();
    List<PlaylistEntity> playlists = [];
    playlistsResult.fold(
      (error) {
        debugPrint('Playlists error: $error');
      },
      (playlistsData) {
        playlists = playlistsData;
      },
    );

    print('Loaded ${songs.length} songs and ${playlists.length} playlists');
    if (!isClosed) {
      final newState = LibraryLoaded(
        recentItems: songs,
        playlists: playlists,
        filter: LibraryFilter.all,
      );
      emit(newState);
      print('Library state emitted with ${playlists.length} playlists');
      for (var playlist in playlists) {
        print('- ${playlist.name} (${playlist.songs.length} songs)');
      }
    }
    print('Library loaded successfully');
    print('==============================');
  }

  void changeFilter(LibraryFilter filter) {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      emit(currentState.copyWith(filter: filter));
    }
  }
}
