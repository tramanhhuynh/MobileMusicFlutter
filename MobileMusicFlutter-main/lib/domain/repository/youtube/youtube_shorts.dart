import 'package:dartz/dartz.dart';
import 'package:music_player/data/sources/youtube/youtube_shorts_service.dart';

abstract class YouTubeShortsRepository {
  Future<Either<String, List<YouTubeShortsVideo>>> getMusicShorts({
    int maxResults = 20,
    String? regionCode,
  });

  Future<Either<String, List<YouTubeShortsVideo>>> getShortsByKeyword({
    required String keyword,
    int maxResults = 20,
    String? regionCode,
  });

  Future<Either<String, YouTubeVideoDetails>> getVideoDetails(String videoId);
} 