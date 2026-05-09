import 'package:dartz/dartz.dart';
import 'package:music_player/data/sources/youtube/youtube_shorts_service.dart';
import 'package:music_player/domain/repository/youtube/youtube_shorts.dart';

class YouTubeShortsRepositoryImpl implements YouTubeShortsRepository {
  final YouTubeShortsService _service;

  YouTubeShortsRepositoryImpl(this._service);

  @override
  Future<Either<String, List<YouTubeShortsVideo>>> getMusicShorts({
    int maxResults = 20,
    String? regionCode,
  }) async {
    return await _service.getMusicShorts(
      maxResults: maxResults,
      regionCode: regionCode,
    );
  }

  @override
  Future<Either<String, List<YouTubeShortsVideo>>> getShortsByKeyword({
    required String keyword,
    int maxResults = 20,
    String? regionCode,
  }) async {
    return await _service.getShortsByKeyword(
      keyword: keyword,
      maxResults: maxResults,
      regionCode: regionCode,
    );
  }

  @override
  Future<Either<String, YouTubeVideoDetails>> getVideoDetails(String videoId) async {
    return await _service.getVideoDetails(videoId);
  }
} 