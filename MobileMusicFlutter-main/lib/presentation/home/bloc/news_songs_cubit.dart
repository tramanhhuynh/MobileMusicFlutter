import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:music_player/domain/usecases/song/get_news_songs.dart';
import 'package:music_player/presentation/home/bloc/news_songs_state.dart';
import 'package:music_player/service_locator.dart';

class NewsSongsCubit extends Cubit<NewsSongsState> {
  NewsSongsCubit() : super(NewsSongsLoading());
  Future<void> getNewsSongs() async {
    var returnedSongs = await sl<GetNewsSongsUseCase>().call();

    returnedSongs.fold(
      (l) {
        if (!isClosed) emit(NewsSongsLoadFailure());
      },
      (data) {
        if (!isClosed) emit(NewsSongsLoaded(songs: data));
      },
    );
  }
}
