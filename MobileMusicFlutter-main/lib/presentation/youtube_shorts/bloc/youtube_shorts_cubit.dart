import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/usecases/youtube/get_music_shorts.dart';
import 'package:music_player/domain/usecases/youtube/get_shorts_by_keyword.dart';
import 'package:music_player/presentation/youtube_shorts/bloc/youtube_shorts_state.dart';
import 'package:music_player/service_locator.dart';

class YouTubeShortsCubit extends Cubit<YouTubeShortsState> {
  YouTubeShortsCubit() : super(YouTubeShortsInitial());

  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _isLoadingMore = false;

  /// Tải danh sách music shorts ban đầu
  Future<void> loadMusicShorts() async {
    if (state is YouTubeShortsLoading) return;
    
    emit(YouTubeShortsLoading());
    
    final result = await sl<GetMusicShortsUseCase>().call(
      params: {'maxResults': _pageSize},
    );

    result.fold(
      (error) => emit(YouTubeShortsError(error)),
      (videos) => emit(YouTubeShortsLoaded(videos: videos)),
    );
  }

  /// Tải thêm shorts khi scroll
  Future<void> loadMoreShorts() async {
    if (_isLoadingMore || state is! YouTubeShortsLoaded) return;
    
    final currentState = state as YouTubeShortsLoaded;
    if (currentState.hasReachedMax) return;

    _isLoadingMore = true;
    _currentPage++;

    final result = await sl<GetMusicShortsUseCase>().call(
      params: {
        'maxResults': _pageSize,
        'pageToken': _currentPage.toString(),
      },
    );

    result.fold(
      (error) {
        _isLoadingMore = false;
        emit(YouTubeShortsError(error));
      },
      (newVideos) {
        _isLoadingMore = false;
        if (newVideos.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          final allVideos = [...currentState.videos, ...newVideos];
          emit(currentState.copyWith(videos: allVideos));
        }
      },
    );
  }

  /// Tìm kiếm shorts theo từ khóa
  Future<void> searchShorts(String keyword) async {
    if (state is YouTubeShortsLoading) return;
    
    emit(YouTubeShortsLoading());
    _currentPage = 0;

    final result = await sl<GetShortsByKeywordUseCase>().call(
      params: {
        'keyword': keyword,
        'maxResults': _pageSize,
      },
    );

    result.fold(
      (error) => emit(YouTubeShortsError(error)),
      (videos) => emit(YouTubeShortsLoaded(videos: videos)),
    );
  }

  /// Refresh danh sách
  Future<void> refreshShorts() async {
    _currentPage = 0;
    _isLoadingMore = false;
    await loadMusicShorts();
  }

  /// Kiểm tra xem có cần load thêm không
  bool shouldLoadMore(int index) {
    if (state is! YouTubeShortsLoaded) return false;
    
    final currentState = state as YouTubeShortsLoaded;
    return index >= currentState.videos.length - 3 && 
           !currentState.hasReachedMax && 
           !_isLoadingMore;
  }
} 