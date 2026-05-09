import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/data/sources/youtube/youtube_shorts_service.dart';
import 'package:music_player/service_locator.dart';

class GetMusicShortsUseCase implements UseCase<Either<String, List<YouTubeShortsVideo>>, Map<String, dynamic>> {
  @override
  Future<Either<String, List<YouTubeShortsVideo>>> call({Map<String, dynamic>? params}) async {
    final maxResults = params?['maxResults'] ?? 20;
    final regionCode = params?['regionCode'];
    
    return await sl<YouTubeShortsService>().getMusicShorts(
      maxResults: maxResults,
      regionCode: regionCode,
    );
  }
} 