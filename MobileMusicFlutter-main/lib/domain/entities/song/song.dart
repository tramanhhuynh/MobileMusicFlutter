import 'package:cloud_firestore/cloud_firestore.dart';

class SongEntity {
  final String title;
  final String artist;
  final num duration;
  final Timestamp releaseDate;
  bool isFavorite; // Đổi từ final sang non-final để có thể gán lại
  final String? colorB; // thêm trường này

  final String songId;

  SongEntity({
    required this.title,
    required this.artist,
    required this.duration,
    required this.releaseDate,
    required this.isFavorite,
    required this.songId,
    this.colorB, // thêm vào constructor
  });

  // Thêm phương thức copyWith để tạo bản sao với các giá trị được cập nhật
  SongEntity copyWith({
    String? title,
    String? artist,
    num? duration,
    Timestamp? releaseDate,
    bool? isFavorite,
    String? songId,
    String? colorB, // thêm vào copyWith
  }) {
    return SongEntity(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      isFavorite: isFavorite ?? this.isFavorite,
      songId: songId ?? this.songId,
      colorB: colorB ?? this.colorB,
    );
  }
}
