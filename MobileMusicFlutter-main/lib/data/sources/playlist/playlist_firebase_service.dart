import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_player/data/models/playlist/playlist.dart';
import 'package:music_player/domain/entities/playlist/playlist.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/data/models/song/song.dart';
import 'package:music_player/domain/usecases/song/is_favorite_song.dart';
import 'package:music_player/service_locator.dart';

abstract class PlaylistFirebaseService {
  Future<Either<String, List<PlaylistEntity>>> getUserPlaylists();
  Future<Either<String, PlaylistEntity>> createPlaylist(String name);
  Future<Either<String, PlaylistEntity>> addSongToPlaylist(String playlistId, String songId);
  Future<Either<String, PlaylistEntity>> removeSongFromPlaylist(String playlistId, String songId);
  Future<Either<String, void>> deletePlaylist(String playlistId);
}

class PlaylistFirebaseServiceImpl extends PlaylistFirebaseService {
  @override
  Future<Either<String, List<PlaylistEntity>>> getUserPlaylists() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left('Người dùng chưa đăng nhập');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .orderBy('createdAt', descending: true)
          .get();

      final playlists = await Future.wait(
        snapshot.docs.map((doc) async {
          final model = PlaylistModel.fromJson(doc.data());
          model.id = doc.id;
          
          // Lấy thông tin bài hát trong playlist theo đúng thứ tự
          if (model.songIds != null && model.songIds!.isNotEmpty) {
            List<SongEntity> orderedSongs = [];
            for (String songId in model.songIds!) {
              final songDoc = await FirebaseFirestore.instance
                  .collection('Songs')
                  .doc(songId)
                  .get();
              
              if (songDoc.exists) {
                final songModel = SongModel.fromJson(songDoc.data()!);
                songModel.songId = songId;
                songModel.isFavorite = await sl<IsFavoriteSongUseCase>().call(params: songId);
                orderedSongs.add(songModel.toEntity());
              }
            }
            model.songs = orderedSongs;
          } else {
            model.songs = [];
          }
          
          return model.toEntity();
        }),
      );

      return Right(playlists);
    } catch (e) {
      return Left('Lỗi khi lấy danh sách playlist: $e');
    }
  }

  @override
  Future<Either<String, PlaylistEntity>> createPlaylist(String name) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left('Người dùng chưa đăng nhập');
      }

      final docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .add({
        'name': name,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
        'songIds': [],
      });

      final playlist = PlaylistEntity(
        id: docRef.id,
        name: name,
        userId: user.uid,
        createdAt: DateTime.now(),
        songIds: [],
        songs: [],
      );

      return Right(playlist);
    } catch (e) {
      return Left('Lỗi khi tạo playlist: $e');
    }
  }

  @override
  Future<Either<String, PlaylistEntity>> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left('Người dùng chưa đăng nhập');
      }

      final playlistRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId);

      // Kiểm tra xem bài hát đã có trong playlist chưa
      final playlistDoc = await playlistRef.get();
      if (!playlistDoc.exists) {
        return Left('Playlist không tồn tại');
      }

      final data = playlistDoc.data()!;
      List<String> songIds = List<String>.from(data['songIds'] ?? []);
      
      if (!songIds.contains(songId)) {
        songIds.add(songId);
        await playlistRef.update({'songIds': songIds});
      }

      // Lấy thông tin tất cả bài hát trong playlist theo đúng thứ tự
      List<SongEntity> allSongs = [];
      if (songIds.isNotEmpty) {
        for (String songId in songIds) {
          final songDoc = await FirebaseFirestore.instance
              .collection('Songs')
              .doc(songId)
              .get();
          
          if (songDoc.exists) {
            final songModel = SongModel.fromJson(songDoc.data()!);
            songModel.songId = songId;
            songModel.isFavorite = await sl<IsFavoriteSongUseCase>().call(params: songId);
            allSongs.add(songModel.toEntity());
          }
        }
      }

      // Tạo playlist entity với tất cả bài hát
      final playlist = PlaylistEntity(
        id: playlistId,
        name: data['name'],
        userId: user.uid,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        songIds: songIds,
        songs: allSongs,
      );

      return Right(playlist);
    } catch (e) {
      return Left('Lỗi khi thêm bài hát vào playlist: $e');
    }
  }

  @override
  Future<Either<String, PlaylistEntity>> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left('Người dùng chưa đăng nhập');
      }

      final playlistRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId);

      final playlistDoc = await playlistRef.get();
      if (!playlistDoc.exists) {
        return Left('Playlist không tồn tại');
      }

      final data = playlistDoc.data()!;
      List<String> songIds = List<String>.from(data['songIds'] ?? []);
      songIds.remove(songId);
      
      await playlistRef.update({'songIds': songIds});

      // Lấy thông tin các bài hát còn lại trong playlist theo đúng thứ tự
      List<SongEntity> remainingSongs = [];
      if (songIds.isNotEmpty) {
        for (String songId in songIds) {
          final songDoc = await FirebaseFirestore.instance
              .collection('Songs')
              .doc(songId)
              .get();
          
          if (songDoc.exists) {
            final songModel = SongModel.fromJson(songDoc.data()!);
            songModel.songId = songId;
            songModel.isFavorite = await sl<IsFavoriteSongUseCase>().call(params: songId);
            remainingSongs.add(songModel.toEntity());
          }
        }
      }

      final playlist = PlaylistEntity(
        id: playlistId,
        name: data['name'],
        userId: user.uid,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        songIds: songIds,
        songs: remainingSongs,
      );

      return Right(playlist);
    } catch (e) {
      return Left('Lỗi khi xóa bài hát khỏi playlist: $e');
    }
  }

  @override
  Future<Either<String, void>> deletePlaylist(String playlistId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left('Người dùng chưa đăng nhập');
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Playlists')
          .doc(playlistId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left('Lỗi khi xóa playlist: $e');
    }
  }
} 