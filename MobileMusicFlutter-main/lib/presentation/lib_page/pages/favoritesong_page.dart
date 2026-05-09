import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:music_player/presentation/profile/bloc/profile_info_state.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/presentation/comon/widgets/mini_player_bar/mini_player_bar.dart';
import 'package:music_player/domain/entities/song/song.dart';

class FavoriteSongsDetailPage extends StatelessWidget {
  const FavoriteSongsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Bài hát đã thích',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocProvider(
        create: (_) => ProfileInfoCubit()..getUser(),
        child: BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
          builder: (context, userState) {
            if (userState is ProfileInfoLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (userState is ProfileInfoLoaded) {
              final user = userState.userEntity;
              return Column(
                children: [
                  // Header với thông tin
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Hình ảnh
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(72, 17, 240, 1),
                                Color.fromRGBO(173, 207, 206, 1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
                                builder: (context, state) {
                                  final bool showPlay = state is FavoriteSongsLoaded && state.favoriteSongs.isNotEmpty;
                                  final songs = showPlay ? (state as FavoriteSongsLoaded).favoriteSongs : <SongEntity>[];
                                  
                                  return Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Bài hát đã thích',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (showPlay)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => SongPlayerPage(
                                                  songList: songs,
                                                  currentIndex: 0,
                                                  isAlbum: false,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent,
                                              borderRadius: BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blueAccent.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.fullName ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
                                builder: (context, state) {
                                  final songCount = state is FavoriteSongsLoaded ? state.favoriteSongs.length : 0;
                                  return Text(
                                    '$songCount bài hát',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tạo ngày ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Danh sách bài hát
                  Expanded(
                    child: BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
                      builder: (context, state) {
                        if (state is FavoriteSongsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        }
                        if (state is FavoriteSongsLoaded) {
                          final songs = state.favoriteSongs;
                          if (songs.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    color: Colors.white54,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có bài hát nào',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Thêm bài hát vào danh sách yêu thích',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: songs.length,
                            separatorBuilder:
                                (_, __) => const Divider(
                                  color: Colors.white12,
                                  thickness: 0.5,
                                  height: 1,
                                ),
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatDuration(song.duration),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => SongPlayerPage(
                                            songList: songs,
                                            currentIndex: index,
                                            isAlbum: false,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                        if (state is FavoriteSongsFailure) {
                          return const Center(
                            child: Text(
                              'Có lỗi khi tải danh sách yêu thích',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(
              child: Text(
                'Không tìm thấy thông tin user',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const MiniPlayerBar(),
    );
  }

  String _formatDuration(num duration) {
    double durationDouble = duration.toDouble();
    int minutes = durationDouble.floor();
    int seconds = ((durationDouble - minutes) * 100).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
