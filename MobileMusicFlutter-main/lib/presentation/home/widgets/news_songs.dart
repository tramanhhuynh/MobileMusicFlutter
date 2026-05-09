import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/common/helpers/is_dark_mode.dart';
import 'package:music_player/common/widgets/skeleton/skeleton_loading.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/home/bloc/news_songs_cubit.dart';
import 'package:music_player/presentation/home/bloc/news_songs_state.dart';
import 'package:music_player/presentation/song_player/pages/song_player.dart';

class NewsSongs extends StatelessWidget {
  const NewsSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsSongsCubit()..getNewsSongs(),
      child: BlocBuilder<NewsSongsCubit, NewsSongsState>(
          builder: (context, state) {
            if (state is NewsSongsLoading) {
              return const NewsSongsSkeleton();
            }

            if (state is NewsSongsLoaded) {
              return _songs(state.songs);
            }
            return Container();
          },
        ),
      );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final song = songs[index];
        final imageUrl =
            AppUrls.coverfirestorage +
            song.artist +
            ' - ' +
            song.title +
            '.jpg?' +
            AppUrls.mediaAlt;

        return GestureDetector(
          onTap: () {
              print('Số lượng bài hát truyền vào: ${songs.length}, index: $index');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongPlayerPage(
                  songList: songs,
                  currentIndex: index,
                  isAlbum: false,
                ),
              ),
            );
          },
          child: SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  song.artist,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 14),
      itemCount: songs.length,
    );
  }
}
