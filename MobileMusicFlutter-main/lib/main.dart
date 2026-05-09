import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/core/configs/theme/app_themes.dart';

import 'package:music_player/firebase_options.dart';
import 'package:music_player/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:music_player/presentation/search_page/bloc/search_cubit.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:music_player/presentation/splash/pages/splash.dart';
import 'package:path_provider/path_provider.dart';

import 'service_locator.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.music_player.channel.audio',
    androidNotificationChannelName: 'Music playback',
    androidNotificationOngoing: true,
  );

  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => SearchCubit()),
        BlocProvider(create: (_) => sl<SongPlayerCubit>()),
        BlocProvider(create: (_) => FavoriteSongsCubit()..getFavoriteSongs()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder:
            (context, mode) => MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              darkTheme: AppThemes.darkTheme,
              theme: AppThemes.lightTheme,
              home: const SplashPage(),
            ),
      ),
    );
  }
}
