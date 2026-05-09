import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/data/sources/song/song_firebase_service.dart';
import 'package:music_player/service_locator.dart';

class SearchCubit extends Cubit<List<SongEntity>> {
  SearchCubit() : super([]);

  final SongFirebaseService _service = sl<SongFirebaseService>();

  Future<void> searchSongs(String keyword) async {
    if (keyword.trim().isEmpty) {
      emit([]);
      return;
    }

    final result = await _service.searchSongs(keyword);

    result.fold(
      (error) => emit([]),
      (songs) => emit(songs),
    );
  }
}
