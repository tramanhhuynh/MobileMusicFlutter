import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_player/data/models/song/song.dart';
import 'package:music_player/domain/entities/album/album.dart';
import 'package:music_player/domain/entities/song/song.dart';
import 'package:music_player/domain/usecases/song/is_favorite_song.dart';
import 'package:music_player/service_locator.dart';
import 'package:diacritic/diacritic.dart';

abstract class SongFirebaseService {
  Future<Either> getNewsSongs();
  Future<Either> getPlayList();
  Future<Either> addOrRemoveFavoriteSong(String songId);
  Future<bool> isFavoriteSong(String songId);
  Future<Either> getUserFavoriteSongs();
  Future<Either> getBannerSong();
  Future<Either<String, List<SongEntity>>> getSongsInAlbum(String albumId);
  Future<Either<String, List<SongEntity>>> searchSongs(String keyword);
  Future<Either<String, List<AlbumEntity>>> getAllAlbums({int limit = 10});
  Future<Either<String, List<SongEntity>>> getSongsByArtist(String artistName);
}

class SongFirebaseServiceImpl extends SongFirebaseService {
  @override
  Future<Either<String, List<AlbumEntity>>> getAllAlbums({
    int limit = 10,
  }) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Albums')
              .limit(limit)
              .get();
      final albums =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return AlbumEntity(
              id: doc.id,
              albumName: data['albumName'] ?? data['name'] ?? '',
              artist: data['artist'] ?? '',
              coverUrl: data['coverUrl'],
              releaseDate:
                  (data['releaseDate'] is Timestamp)
                      ? (data['releaseDate'] as Timestamp).toDate()
                      : DateTime.now(),
              type: data['type'],
            );
          }).toList();
      return Right(albums);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongsInAlbum(
    String albumId,
  ) async {
    try {
      print('🎵 SongFirebaseService - querying songs for albumId: $albumId');
      final songRefsSnapshot =
          await FirebaseFirestore.instance
              .collection('Albums')
              .doc(albumId)
              .collection('Songs')
              .get();

      // Lấy danh sách ref Firestore path
      print('songRefsSnapshot: $songRefsSnapshot');
      print('songRefsSnapshot.docs: ${songRefsSnapshot.docs.length}');
      final futures = songRefsSnapshot.docs.map((doc) async {
        final refPath =
            (doc['ref'] as DocumentReference)
                .path; // Lấy path từ DocumentReference
        print('refPath runtimeType: ${refPath.runtimeType}, value: $refPath');

        final songDoc = await FirebaseFirestore.instance.doc(refPath).get();
        final data = songDoc.data();
        if (data != null) {
          return SongEntity(
            title: data['title'],
            artist: data['artist'],
            duration: data['duration'],
            releaseDate: data['releaseDate'],
            isFavorite: false,
            songId: songDoc.id,
            colorB: data['colorB'],
          );
        }
        return null;
      });
      final songs =
          (await Future.wait(futures)).whereType<SongEntity>().toList();
      print(
        '✅ SongFirebaseService - found \\${songs.length} songs for album $albumId',
      );
      return Right(songs);
    } catch (e) {
      return Left('Lỗi khi lấy danh sách bài hát trong album');
    }
  }

  // @override
  // Future<Either<String, List<SongEntity>>> getSongsInAlbum(
  //   String albumId,
  // ) async {
  //   try {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     List<SongEntity> songs = [];

  //     // Lấy subcollection songs từ album
  //     final subSongsSnapshot =
  //         await firestore
  //             .collection('Albums')
  //             .doc(albumId)
  //             .collection('Songs')
  //             .get();

  //     for (var doc in subSongsSnapshot.docs) {
  //       // Lấy reference đến bài hát gốc
  //       final ref = doc['ref'] as DocumentReference;

  //       final songSnapshot = await ref.get();

  //       if (songSnapshot.exists) {
  //         final songModel = SongModel.fromJson(
  //           songSnapshot.data() as Map<String, dynamic>,
  //         );
  //         songModel.songId = songSnapshot.id;
  //         songModel.isFavorite = await sl<IsFavoriteSongUseCase>().call(
  //           params: songSnapshot.id,
  //         );
  //         songs.add(songModel.toEntity());
  //       }
  //     }

  //     return Right(songs);
  //   } catch (e) {
  //     return Left('Lỗi khi lấy danh sách bài hát trong album');
  //   }
  // }

  @override
  Future<Either> getNewsSongs() async {
    try {
      List<SongEntity> songs = [];
      var data =
          await FirebaseFirestore.instance
              .collection('Songs')
              .orderBy('releaseDate', descending: true)
              .limit(8)
              .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }

      return Right(songs);
    } catch (e) {
      return const Left('Co loi xay ra ');
    }
  }

  @override
Future<Either> getPlayList() async {
  try {
    List<SongEntity> songs = [];

    // Lấy toàn bộ ID bài hát
    var allDocs = await FirebaseFirestore.instance.collection('Songs').get();
    var allIds = allDocs.docs.map((doc) => doc.id).toList();

    if (allIds.length <= 10) {
      // Nếu dưới hoặc bằng 10 bài thì lấy hết
      for (var doc in allDocs.docs) {
        var songModel = SongModel.fromJson(doc.data());
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(params: doc.id);
        songModel.isFavorite = isFavorite;
        songModel.songId = doc.id;
        songs.add(songModel.toEntity());
      }
    } else {
      // Shuffle danh sách ID và chọn 10 ID đầu tiên
      allIds.shuffle();
      var selectedIds = allIds.take(10);

      for (var id in selectedIds) {
        var doc = await FirebaseFirestore.instance.collection('Songs').doc(id).get();
        var songModel = SongModel.fromJson(doc.data()!);
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(params: id);
        songModel.isFavorite = isFavorite;
        songModel.songId = id;
        songs.add(songModel.toEntity());
      }
    }

    return Right(songs);
  } catch (e) {
    return const Left('Có lỗi xảy ra');
  }
}

  @override
  Future<Either<String, SongEntity>> getBannerSong() async {
    try {
      List<SongEntity> songs = [];

      var data =
          await FirebaseFirestore.instance
              .collection('Songs')
              .where('banner', isEqualTo: true)
              .limit(1)
              .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        bool isFavorite = await sl<IsFavoriteSongUseCase>().call(
          params: element.reference.id,
        );
        songModel.isFavorite = isFavorite;
        songModel.songId = element.reference.id;
        songs.add(songModel.toEntity());
      }

      return Right(songs.first);
    } catch (e) {
      return const Left('Lỗi khi lấy bài hát banner');
    }
  }

  @override
  Future<Either> addOrRemoveFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      late bool isFavorite;
      var user = firebaseAuth.currentUser;
      String uId = user!.uid;

      QuerySnapshot favoriteSongs =
          await firebaseFirestore
              .collection('Users')
              .doc(uId)
              .collection('Favorites')
              .where('songId', isEqualTo: songId)
              .get();

      if (favoriteSongs.docs.isNotEmpty) {
        await favoriteSongs.docs.first.reference.delete();
        isFavorite = false;
      } else {
        await firebaseFirestore
            .collection('Users')
            .doc(uId)
            .collection('Favorites')
            .add({'songId': songId, 'addedDate': Timestamp.now()});
        isFavorite = true;
      }
      return Right(isFavorite);
    } catch (e) {
      return Left('Loi khi them nhac yeu thich');
    }
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      var user = firebaseAuth.currentUser;
      String uId = user!.uid;

      QuerySnapshot favoriteSongs =
          await firebaseFirestore
              .collection('Users')
              .doc(uId)
              .collection('Favorites')
              .where('songId', isEqualTo: songId)
              .get();

      if (favoriteSongs.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Either<String, List<SongEntity>>> searchSongs(String keyword) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final lowerKeyword = removeDiacritics(keyword.trim().toLowerCase());

      final allDocs = await firestore.collection('Songs').get();

      // Nếu keyword rỗng, trả về tất cả bài hát (songId + isFavorite)
      if (lowerKeyword.isEmpty) {
        final songs = await Future.wait(
          allDocs.docs.map((doc) async {
            final model = SongModel.fromJson(doc.data());
            model.songId = doc.id;
            model.isFavorite = await sl<IsFavoriteSongUseCase>().call(
              params: doc.id,
            );
            return model.toEntity();
          }),
        );
        return Right(songs);
      }

      // Nếu có keyword, lọc với normalize text
      final filteredDocs =
          allDocs.docs.where((doc) {
            final data = doc.data();
            final title = removeDiacritics(
              (data['title'] ?? '').toString().toLowerCase(),
            );
            final artist = removeDiacritics(
              (data['artist'] ?? '').toString().toLowerCase(),
            );
            return title.contains(lowerKeyword) ||
                artist.contains(lowerKeyword);
          }).toList();

      // Map dữ liệu lọc được thành entity
      final songs = await Future.wait(
        filteredDocs.map((doc) async {
          final model = SongModel.fromJson(doc.data());
          model.songId = doc.id;
          model.isFavorite = await sl<IsFavoriteSongUseCase>().call(
            params: doc.id,
          );
          return model.toEntity();
        }),
      );

      return Right(songs);
    } catch (e) {
      return Left('Lỗi khi tìm kiếm bài hát: $e');
    }
  }

  @override
  Future<Either> getUserFavoriteSongs() async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      var user = firebaseAuth.currentUser;
      List<SongEntity> favoriteSongs = [];
      String uId = user!.uid;
      QuerySnapshot favoritesSnapshot =
          await firebaseFirestore
              .collection('Users')
              .doc(uId)
              .collection('Favorites')
              .get();
      for (var element in favoritesSnapshot.docs) {
        String songId = element['songId'];
        var song =
            await firebaseFirestore.collection('Songs').doc(songId).get();
        SongModel songModel = SongModel.fromJson(song.data()!);
        songModel.isFavorite = true;
        songModel.songId = songId;
        favoriteSongs.add(songModel.toEntity());
      }
      return Right(favoriteSongs);
    } catch (e) {
      return Left('Loi o API lay bai hat fav');
    }
  }

  @override
  Future<Either<String, List<SongEntity>>> getSongsByArtist(
    String artistName,
  ) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Songs')
              .where('artist', isEqualTo: artistName)
              .get();
      final songs =
          snapshot.docs.map((doc) {
            final model = SongModel.fromJson(doc.data());
            model.songId = doc.id;
            // Optionally set isFavorite if needed
            return model.toEntity();
          }).toList();
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
