import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/usecases/album/get_albums.dart';
import 'package:music_player/domain/entities/song/song.dart';

// Artist Songs State
abstract class ArtistSongsState {}

class ArtistSongsLoading extends ArtistSongsState {}

class ArtistSongsError extends ArtistSongsState {
  final String message;
  ArtistSongsError(this.message);
}

class ArtistSongsLoaded extends ArtistSongsState {
  final List<SongEntity> songs;
  ArtistSongsLoaded(this.songs);
}
class ArtistSongsCubit extends Cubit<ArtistSongsState> {
  final GetSongsByArtistUseCase getSongsByArtistUseCase;
  ArtistSongsCubit(this.getSongsByArtistUseCase) : super(ArtistSongsLoading());

  Future<void> fetchSongs(String artistName) async {
    emit(ArtistSongsLoading());
    final result = await getSongsByArtistUseCase(artistName);
    result.fold(
      (error) => emit(ArtistSongsError(error)),
      (songs) => emit(ArtistSongsLoaded(songs)),
    );
  }
}