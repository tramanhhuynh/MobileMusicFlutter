import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:music_player/presentation/song_player/bloc/song_player_state.dart';

class MiniPlayerControls extends StatelessWidget {
  final BuildContext context;
  final SongPlayerLoaded state;
  final SongPlayerCubit songPlayerCubit;
  final SongEntity song;
  const MiniPlayerControls({
    super.key,
    required this.context,
    required this.state,
    required this.songPlayerCubit,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skip Previous Button
        IconButton(
          icon: const Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            songPlayerCubit.prevSong();
          },
        ),
        // Play/Pause Button
        IconButton(
          icon: Icon(
            state.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            songPlayerCubit.playOrPauseSong();
          },
        ),
        // Skip Next Button
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            songPlayerCubit.nextSong();
          },
        ),
      ],
    );
  }
}
