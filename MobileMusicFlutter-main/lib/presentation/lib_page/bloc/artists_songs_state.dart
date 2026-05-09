import 'package:music_player/domain/entities/song/song.dart';

abstract class ArtistSongsState {}

class ArtistSongsLoading extends ArtistSongsState {}

class ArtistSongsLoaded extends ArtistSongsState {
  final List<SongEntity> songs;
  ArtistSongsLoaded(this.songs);
}

class ArtistSongsError extends ArtistSongsState {
  final String message;
  ArtistSongsError(this.message);
}