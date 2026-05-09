import 'package:equatable/equatable.dart';
import 'package:music_player/domain/entities/song/song.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SongEntity> songs;

  const SearchSuccess(this.songs);

  @override
  List<Object?> get props => [songs];
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
