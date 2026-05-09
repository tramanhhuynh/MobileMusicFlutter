import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/common/widgets/appbar/app_bar.dart';
import 'package:music_player/common/widgets/favorite_button/favorite_button.dart';
import 'package:music_player/common/widgets/music_cd_spinner/music_cd_spinner.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_state.dart';
import 'package:music_player/service_locator.dart';

class SongPlayerPage extends StatefulWidget {
  final List<SongEntity> songList;
  final int currentIndex;
  final bool isAlbum;
  const SongPlayerPage({
    required this.songList,
    required this.currentIndex,
    this.isAlbum = false,
    super.key,
  });

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  SongPlayerCubit? _songPlayerCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lưu reference đến cubit để sử dụng trong dispose
    _songPlayerCubit = context.read<SongPlayerCubit>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<SongPlayerCubit>();
      cubit.setSongList(widget.songList, widget.currentIndex);
      // Khôi phục trạng thái phát nhạc khi vào trang
      cubit.restorePlaybackState();
      // Đảm bảo trạng thái phát nhạc được duy trì
      cubit.ensurePlaybackContinuity();
      // Debug thông tin playlist
      cubit.debugPlaylistInfo();
    });
  }

  @override
  void dispose() {
    // Lưu trạng thái phát nhạc khi rời khỏi trang
    _songPlayerCubit?.savePlaybackState();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: const Text('Đang phát', style: TextStyle(fontSize: 18)),
        action: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
      body: BlocBuilder<SongPlayerCubit, SongPlayerState>(
        builder: (context, state) {
          final cubit = context.read<SongPlayerCubit>();
          final song = cubit.currentSongEntity;
          
          // Lấy thông tin playlist hiện tại
          final currentSongList = cubit.currentSongList;
          final currentIndex = cubit.currentSongIndex;
          final isUsingOriginalPlaylist = cubit.isUsingOriginalPlaylist;
          
          if (state is SongPlayerLoading) {
            return const Center(child: MusicCDSpinner());
          }

          if (state is SongPlayerLoaded && song != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  _songCover(context, song),
                  _songDetail(song),
                  Column(
                    children: [
                      Slider(
                        min: 0,
                        max: state.songDuration.inSeconds.toDouble(),
                        value: state.songPosition.inSeconds.toDouble(),
                        onChanged: (value) {
                          cubit.seekSong(Duration(seconds: value.toInt()));
                        },
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.darkGrey.withAlpha(
                          (0.3 * 255).toInt(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cubit.formatDuration(state.songPosition)),
                            Text(cubit.formatDuration(state.songDuration)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color:
                                  state.isShuffling ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<SongPlayerCubit>().toggleShuffling();
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<SongPlayerCubit>().prevSong(
                                isAlbum: widget.isAlbum,
                              );
                            },
                            icon: const Icon(Icons.skip_previous, size: 40),
                          ),
                          Ink(
                            decoration: const ShapeDecoration(
                              color: AppColors.primary,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              iconSize: 50,
                              color: Colors.white,
                              onPressed: () {
                                cubit.playOrPauseSong();
                              },
                              icon: Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<SongPlayerCubit>().nextSong(
                                isAlbum: widget.isAlbum,
                              );
                            },
                            icon: const Icon(Icons.skip_next, size: 40),
                          ),
                          IconButton(
                            icon: Icon(
                              state.isLooping ? Icons.repeat_one : Icons.repeat,
                              color:
                                  state.isLooping ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<SongPlayerCubit>().toggleLooping();
                            },
                          ),
                        ],
                      ),
                      // Hiển thị thông tin playlist dưới phần điều khiển
                      if (isUsingOriginalPlaylist && currentSongList.length > 1)
                        _playlistInfo(currentSongList, currentIndex),
                    ],
                  ),
                ],
              ),
            );
          }

          if (state is SongPlayerFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget hiển thị ảnh bìa bài hát
  Widget _songCover(BuildContext context, SongEntity song) {
    final double coverSize = MediaQuery.of(context).size.width * 0.9; // Giảm kích thước để đẹp hơn
    return Center(
      child: Hero(
        tag: 'album_cover_${song.songId}',
        child: Container(
          height: coverSize,
          width: coverSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Tăng bo góc
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // Bo góc cho hình ảnh
            child: Image.network(
              '${AppUrls.coverfirestorage}${song.artist} - ${song.title}.jpg?${AppUrls.mediaAlt}',
              fit: BoxFit.cover,
              width: coverSize,
              height: coverSize,
              errorBuilder: (context, error, stackTrace) => Container(
                width: coverSize,
                height: coverSize,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị tiêu đề bài hát và nghệ sĩ
  Widget _songDetail(SongEntity song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Text(
                  song.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  song.artist,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          FavoriteButton(songEntity: song),
        ],
      ),
    );
  }

  // Thêm widget để hiển thị thông tin playlist
  Widget _playlistInfo(List<SongEntity> songList, int currentIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.playlist_play, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Playlist: ${currentIndex + 1}/${songList.length} bài hát',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
