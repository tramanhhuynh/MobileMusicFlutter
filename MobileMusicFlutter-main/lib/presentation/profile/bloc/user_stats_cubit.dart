import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/usecases/song/get_favorite_songs.dart';
import 'package:music_player/domain/usecases/playlist/get_user_playlists.dart';
import 'package:music_player/service_locator.dart';

// States
abstract class UserStatsState {}

class UserStatsLoading extends UserStatsState {}

class UserStatsLoaded extends UserStatsState {
  final int favoriteSongsCount;
  final int playlistsCount;
  final int listenedSongsCount;
  
  UserStatsLoaded({
    required this.favoriteSongsCount,
    required this.playlistsCount,
    required this.listenedSongsCount,
  });
}

class UserStatsFailure extends UserStatsState {
  final String message;
  UserStatsFailure(this.message);
}

// Cubit
class UserStatsCubit extends Cubit<UserStatsState> {
  UserStatsCubit() : super(UserStatsLoading());

  Future<void> loadUserStats() async {
    if (!isClosed) emit(UserStatsLoading());
    
    try {
      // Load favorite songs count
      final favoriteSongsResult = await sl<GetFavoriteSongsUseCase>().call();
      int favoriteSongsCount = 0;
      favoriteSongsResult.fold(
        (failure) => print('Failed to load favorite songs: $failure'),
        (songs) => favoriteSongsCount = songs.length,
      );

      // Load playlists count
      final playlistsResult = await sl<GetUserPlaylistsUseCase>().call();
      int playlistsCount = 0;
      playlistsResult.fold(
        (failure) => print('Failed to load playlists: $failure'),
        (playlists) => playlistsCount = playlists.length,
      );

      // For now, we'll use a placeholder for listened songs count
      // In a real app, this would come from a listening history service
      int listenedSongsCount = favoriteSongsCount * 3; // Placeholder calculation

      if (!isClosed) {
        emit(UserStatsLoaded(
          favoriteSongsCount: favoriteSongsCount,
          playlistsCount: playlistsCount,
          listenedSongsCount: listenedSongsCount,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(UserStatsFailure('Failed to load user statistics: $e'));
      }
    }
  }
} 