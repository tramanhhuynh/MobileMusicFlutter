import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/common/helpers/is_dark_mode.dart';
import 'package:music_player/common/widgets/favorite_button/favorite_button.dart';
import 'package:music_player/common/widgets/skeleton/skeleton_loading.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/home/bloc/play_list_cubit.dart';
import 'package:music_player/presentation/home/bloc/play_list_state.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';

class PlayList extends StatelessWidget {
  const PlayList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayListCubit()..getPlayList(),
      child: BlocBuilder<PlayListCubit, PlayListState>(
        builder: (context, state) {
          if (state is PlayListLoading) {
            return const PlayListSkeleton();
          }

          if (state is PlayListLoaded) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Có thể bạn sẽ thích',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _songs(state.songs),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Material(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (BuildContext context) => SongPlayerPage(
                          songList: [songs[index]],
                          currentIndex: 0,
                          isAlbum: false,
                        ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  children: [
                    // Số thứ tự
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Ảnh vuông
                    const SizedBox(width: 12),
                    // Tiêu đề và artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            songs[index].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            songs[index].artist,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Duration
                    Text(
                      formatDuration(songs[index].duration),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Favorite button
                    FavoriteButton(songEntity: songs[index]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: songs.length,
    );
  }

  String formatDuration(num duration) {
    double durationDouble = duration.toDouble(); // ép kiểu rõ ràng
    int minutes = durationDouble.floor();
    int seconds = ((durationDouble - minutes) * 100).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
