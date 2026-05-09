import 'package:flutter/material.dart';
import 'package:music_player/domain/entities/song/song.dart';

class MiniPlayerSongInfo extends StatelessWidget {
  final SongEntity song;
  const MiniPlayerSongInfo({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        Text(
          song.artist,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}
