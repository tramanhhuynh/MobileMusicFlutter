import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/usecases/song/get_songs_by_album.dart';

abstract class AlbumSongsState {}

class AlbumSongsLoading extends AlbumSongsState {}

class AlbumSongsLoaded extends AlbumSongsState {
  final List<SongEntity> songs;
  AlbumSongsLoaded(this.songs);
}

class AlbumSongsError extends AlbumSongsState {
  final String message;
  AlbumSongsError(this.message);
}

class AlbumSongsCubit extends Cubit<AlbumSongsState> {
  final GetSongsByAlbumUseCase getSongsByAlbumUseCase;
  AlbumSongsCubit(this.getSongsByAlbumUseCase) : super(AlbumSongsLoading());

  Future<void> fetchSongs(String albumId) async {
    print('🎵 AlbumSongsCubit - fetching songs for albumId: $albumId');
    emit(AlbumSongsLoading());
    final result = await getSongsByAlbumUseCase(albumId);
    result.fold(
      (error) {
        print('❌ AlbumSongsCubit - error: $error');
        emit(AlbumSongsError(error));
      },
      (songs) {
        print('✅ AlbumSongsCubit - loaded ${songs.length} songs for album $albumId');
        emit(AlbumSongsLoaded(songs));
      },
    );
  }
}
