import 'package:get_it/get_it.dart';
import 'package:music_player/data/repository/auth/auth_repository_impl.dart';
import 'package:music_player/data/repository/song/song_repository_impl.dart';
import 'package:music_player/data/repository/playlist/playlist_repository_impl.dart';
import 'package:music_player/data/sources/auth/auth_firebase_service.dart';
import 'package:music_player/data/sources/song/song_firebase_service.dart';
import 'package:music_player/data/sources/playlist/playlist_firebase_service.dart';
import 'package:music_player/domain/repository/auth/auth.dart';
import 'package:music_player/domain/repository/song/song.dart';
import 'package:music_player/domain/repository/playlist/playlist.dart';
import 'package:music_player/domain/usecases/auth/get_user.dart';
import 'package:music_player/domain/usecases/auth/signin.dart';
import 'package:music_player/domain/usecases/auth/signup.dart';
import 'package:music_player/domain/usecases/song/add_or_remove_song.dart';
import 'package:music_player/domain/usecases/song/get_favorite_songs.dart';
import 'package:music_player/domain/usecases/song/get_news_songs.dart';
import 'package:music_player/domain/usecases/song/get_play_list.dart';
import 'package:music_player/domain/usecases/song/is_favorite_song.dart';
import 'package:music_player/domain/usecases/album/get_albums.dart';
import 'package:music_player/domain/usecases/song/get_songs_by_album.dart';
import 'package:music_player/domain/usecases/playlist/get_user_playlists.dart';
import 'package:music_player/domain/usecases/playlist/create_playlist.dart';
import 'package:music_player/domain/usecases/playlist/add_song_to_playlist.dart';
import 'package:music_player/domain/usecases/playlist/remove_song_from_playlist.dart';
import 'package:music_player/domain/usecases/playlist/delete_playlist.dart';
import 'package:music_player/domain/usecases/youtube/get_music_shorts.dart';
import 'package:music_player/domain/usecases/youtube/get_shorts_by_keyword.dart';
import 'package:music_player/data/sources/youtube/youtube_shorts_service.dart';
import 'package:music_player/data/repository/youtube/youtube_shorts_repository_impl.dart';
import 'package:music_player/domain/repository/youtube/youtube_shorts.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<GetSongsByArtistUseCase>(
    () => GetSongsByArtistUseCase(sl<SongFirebaseService>()),
  );
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());

  sl.registerSingleton<SongFirebaseService>(SongFirebaseServiceImpl());

  sl.registerSingleton<PlaylistFirebaseService>(PlaylistFirebaseServiceImpl());

  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  sl.registerSingleton<SongsRepository>(SongRepositoryImpl());

  sl.registerSingleton<PlaylistRepository>(PlaylistRepositoryImpl(sl<PlaylistFirebaseService>()));

  sl.registerSingleton<SignupUseCase>(SignupUseCase());

  sl.registerSingleton<SigninUseCase>(SigninUseCase());

  sl.registerSingleton<GetNewsSongsUseCase>(GetNewsSongsUseCase());

  sl.registerSingleton<GetPlayListUseCase>(GetPlayListUseCase());

  sl.registerSingleton<AddOrRemoveFavoriteSongUseCase>(
    AddOrRemoveFavoriteSongUseCase(),
  );

  sl.registerSingleton<IsFavoriteSongUseCase>(IsFavoriteSongUseCase());

  sl.registerSingleton<GetUserUseCase>(GetUserUseCase());

  sl.registerSingleton<GetFavoriteSongsUseCase>(GetFavoriteSongsUseCase());

  sl.registerLazySingleton<GetAlbumsUseCase>(
    () => GetAlbumsUseCase(sl<SongFirebaseService>()),
  );

  sl.registerLazySingleton<GetSongsByAlbumUseCase>(
    () => GetSongsByAlbumUseCase(sl<SongsRepository>()),
  );

  sl.registerSingleton<GetUserPlaylistsUseCase>(GetUserPlaylistsUseCase());

  sl.registerSingleton<CreatePlaylistUseCase>(CreatePlaylistUseCase());

  sl.registerSingleton<AddSongToPlaylistUseCase>(AddSongToPlaylistUseCase());

  sl.registerSingleton<RemoveSongFromPlaylistUseCase>(RemoveSongFromPlaylistUseCase());

  sl.registerSingleton<DeletePlaylistUseCase>(DeletePlaylistUseCase());

  // YouTube Shorts dependencies
  sl.registerSingleton<YouTubeShortsService>(YouTubeShortsService());
  sl.registerSingleton<YouTubeShortsRepository>(YouTubeShortsRepositoryImpl(sl<YouTubeShortsService>()));
  sl.registerLazySingleton<GetMusicShortsUseCase>(
    () => GetMusicShortsUseCase(),
  );
  sl.registerLazySingleton<GetShortsByKeywordUseCase>(
    () => GetShortsByKeywordUseCase(),
  );

  // Register global SongPlayerCubit
  sl.registerLazySingleton<SongPlayerCubit>(() => SongPlayerCubit());
}
