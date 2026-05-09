import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/usecases/song/get_favorite_songs.dart';
import 'package:music_player/domain/usecases/song/add_or_remove_song.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:music_player/service_locator.dart';

class FavoriteSongsCubit extends Cubit<FavoriteSongsState> {
  FavoriteSongsCubit() : super(FavoriteSongsLoading());

  List<SongEntity> favoriteSongs = [];
  Future<void> getFavoriteSongs() async {
    var result = await sl<GetFavoriteSongsUseCase>().call();
    result.fold(
      (l) {
        if (!isClosed) emit(FavoriteSongsFailure());
      },
      (r) {
        favoriteSongs = r;
        if (!isClosed) emit(FavoriteSongsLoaded(favoriteSongs: favoriteSongs));
      },
    );
  }

  void removeSong(int index) {
    favoriteSongs.removeAt(index);
    if (!isClosed) {
      emit(FavoriteSongsLoaded(favoriteSongs: favoriteSongs));
    }
  }

  Future<void> toggleFavorite(SongEntity song) async {
    var result = await sl<AddOrRemoveFavoriteSongUseCase>().call(params: song.songId);
    result.fold(
      (l) {},
      (isFavorite) async {
        await getFavoriteSongs();
      },
    );
  }
}
