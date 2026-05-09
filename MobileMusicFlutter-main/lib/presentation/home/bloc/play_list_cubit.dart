import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:music_player/domain/usecases/song/get_play_list.dart';
import 'package:music_player/presentation/home/bloc/play_list_state.dart';
import 'package:music_player/service_locator.dart';

class PlayListCubit extends Cubit<PlayListState> {
  PlayListCubit() : super(PlayListLoading());
  Future<void> getPlayList() async {
    var returnedSongs = await sl<GetPlayListUseCase>().call();

    returnedSongs.fold(
      (l) {
        if (!isClosed) emit(PlayListLoadFailure());
      },
      (data) {
        if (!isClosed) emit(PlayListLoaded(songs: data));
      },
    );
  }
}
