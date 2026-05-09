import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/presentation/lib_page/bloc/album_songs_cubit.dart';
import 'package:music_player/presentation/lib_page/widgets/lib_item_tile.dart';
import 'package:music_player/presentation/lib_page/widgets/lib_recent_grid.dart';
import 'package:music_player/presentation/lib_page/widgets/lib_tab_bar.dart';
import 'package:music_player/service_locator.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/usecases/song/get_songs_by_album.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/common/widgets/favorite_button/favorite_button.dart';
import 'package:music_player/presentation/comon/widgets/mini_player_bar/mini_player_bar.dart';

class AlbumDetailPage extends StatelessWidget {
  final String albumId;
  final String albumName;
  final String artist;
  final String coverUrl; // Nếu có ảnh bìa
  final String releaseDate;

  const AlbumDetailPage({
    Key? key,
    required this.albumId,
    required this.albumName,
    required this.artist,
    required this.coverUrl,
    required this.releaseDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              AlbumSongsCubit(sl<GetSongsByAlbumUseCase>())
                ..fetchSongs(albumId),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Album: ' + albumName,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Header với thông tin album
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Hình ảnh album
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        AppUrls.albumCoverfirestorage +
                            Uri.encodeComponent(albumName) +
                            '.jpg?' +
                            AppUrls.mediaAlt,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<AlbumSongsCubit, AlbumSongsState>(
                          builder: (context, state) {
                            final bool showPlay = state is AlbumSongsLoaded && state.songs.isNotEmpty;
                            final songs = showPlay ? (state as AlbumSongsLoaded).songs : <SongEntity>[];
                            
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    albumName,
                                    style: const TextStyle(
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
                                            isAlbum: true,
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
                          artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<AlbumSongsCubit, AlbumSongsState>(
                          builder: (context, state) {
                            final songCount = state is AlbumSongsLoaded ? state.songs.length : 0;
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
                          'Phát hành ngày ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
              child: BlocBuilder<AlbumSongsCubit, AlbumSongsState>(
                builder: (context, state) {
                  if (state is AlbumSongsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (state is AlbumSongsLoaded) {
                    final songs = state.songs;
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
                                formatDuration(song.duration),
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
                                      isAlbum: true,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  if (state is AlbumSongsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const MiniPlayerBar(),
      ),
    );
  }
  String formatDuration(num duration) {
  double durationDouble = duration.toDouble(); // ép kiểu rõ ràng
  int minutes = durationDouble.floor();
  int seconds = ((durationDouble - minutes) * 100).round();
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
}
