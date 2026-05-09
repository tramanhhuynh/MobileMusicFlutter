import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dartz/dartz.dart';

class YouTubeShortsService {
  static const String _apiKey = 'AIzaSyBDBJJwtjncXegL2VvEHkG40DGOX_5-b-8'; // Cần thay thế bằng API key thực
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Lấy danh sách YouTube Shorts về music
  Future<Either<String, List<YouTubeShortsVideo>>> getMusicShorts({
    int maxResults = 20,
    String? regionCode,
  }) async {
    try {
      final queryParams = {
        'part': 'snippet',
        'type': 'video',
        'videoDuration': 'short', // Lọc video ngắn
        'q': 'em xinh say hi 2025', // Từ khóa tìm kiếm
        'maxResults': maxResults.toString(),
        'key': _apiKey,
        'order': 'relevance', // Sắp xếp theo độ liên quan
      };

      if (regionCode != null) {
        queryParams['regionCode'] = regionCode;
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        
        final videos = items.map((item) {
          return YouTubeShortsVideo.fromJson(item);
        }).toList();

        return Right(videos);
      } else {
        return Left('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Lỗi kết nối: $e');
    }
  }

  /// Lấy Shorts theo từ khóa tùy chỉnh
  Future<Either<String, List<YouTubeShortsVideo>>> getShortsByKeyword({
    required String keyword,
    int maxResults = 20,
    String? regionCode,
  }) async {
    try {
      final queryParams = {
        'part': 'snippet',
        'type': 'video',
        'videoDuration': 'short',
        'q': keyword,
        'maxResults': maxResults.toString(),
        'key': _apiKey,
        'order': 'relevance',
      };

      if (regionCode != null) {
        queryParams['regionCode'] = regionCode;
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        
        final videos = items.map((item) {
          return YouTubeShortsVideo.fromJson(item);
        }).toList();

        return Right(videos);
      } else {
        return Left('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Lỗi kết nối: $e');
    }
  }

  /// Lấy chi tiết video
  Future<Either<String, YouTubeVideoDetails>> getVideoDetails(String videoId) async {
    try {
      final queryParams = {
        'part': 'snippet,statistics,contentDetails',
        'id': videoId,
        'key': _apiKey,
      };

      final uri = Uri.parse('$_baseUrl/videos').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        
        if (items.isNotEmpty) {
          final videoDetails = YouTubeVideoDetails.fromJson(items.first);
          return Right(videoDetails);
        } else {
          return Left('Không tìm thấy video');
        }
      } else {
        return Left('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Lỗi kết nối: $e');
    }
  }
}

class YouTubeShortsVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String channelId;
  final DateTime publishedAt;
  final bool isShorts;

  YouTubeShortsVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    this.isShorts = true,
  });

  factory YouTubeShortsVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final id = json['id']['videoId'] ?? '';
    
    return YouTubeShortsVideo(
      id: id,
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      channelId: snippet['channelId'] ?? '',
      publishedAt: DateTime.parse(snippet['publishedAt']),
      isShorts: true,
    );
  }

  String get shortsUrl => 'https://www.youtube.com/shorts/$id';
  String get watchUrl => 'https://www.youtube.com/watch?v=$id';
}

class YouTubeVideoDetails {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String channelId;
  final DateTime publishedAt;
  final String duration;
  final int viewCount;
  final int likeCount;
  final int commentCount;

  YouTubeVideoDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
  });

  factory YouTubeVideoDetails.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final statistics = json['statistics'];
    final contentDetails = json['contentDetails'];
    
    return YouTubeVideoDetails(
      id: json['id'] ?? '',
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      channelId: snippet['channelId'] ?? '',
      publishedAt: DateTime.parse(snippet['publishedAt']),
      duration: contentDetails['duration'] ?? '',
      viewCount: int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
      likeCount: int.tryParse(statistics['likeCount'] ?? '0') ?? 0,
      commentCount: int.tryParse(statistics['commentCount'] ?? '0') ?? 0,
    );
  }

  bool get isShorts {
    return _parseDuration(duration) < const Duration(minutes: 1);
  }

  Duration _parseDuration(String duration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    
    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
      
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    
    return Duration.zero;
  }
} 