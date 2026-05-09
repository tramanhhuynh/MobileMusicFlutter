import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_cubit.dart';
import 'package:music_player/presentation/profile/bloc/favorite_songs_state.dart';
import 'package:music_player/core/configs/theme/app_colors.dart';
import 'package:music_player/domain/entities/song/song.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  final Function? function;
  const FavoriteButton({required this.songEntity, this.function, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteSongsCubit, FavoriteSongsState>(
      builder: (context, state) {
        bool currentIsFavorite = songEntity.isFavorite;
        if (state is FavoriteSongsLoaded) {
          final found = state.favoriteSongs.any((s) => s.songId == songEntity.songId);
          currentIsFavorite = found;
        }
        return IconButton(
          onPressed: () async {
            await context.read<FavoriteSongsCubit>().toggleFavorite(songEntity);
            if (function != null) {
              function!();
            }
          },
          icon: Icon(
            currentIsFavorite
                ? Icons.favorite
                : Icons.favorite_outline_outlined,
            size: 25,
            color: currentIsFavorite ? Colors.red : AppColors.darkGrey,
          ),
        );
      },
    );
  }
}