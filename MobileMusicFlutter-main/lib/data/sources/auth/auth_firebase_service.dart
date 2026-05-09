import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_player/core/configs/constants/app_urls.dart';
import 'package:music_player/data/models/auth/create_user_req.dart';
import 'package:music_player/data/models/auth/signin_user_req.dart';
import 'package:music_player/data/models/auth/user.dart';
import 'package:music_player/domain/entities/auth/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class AuthFirebaseService {
  Future<Either> signup(CreateUserReq createUserReq);
  Future<Either> signin(SigninUserReq signinUserReq);
  Future<Either> getUser();
  Future<Either> signOut();
  Future<Either> updateName(String newName);
  Future<Either> updateImage(String imagePath);
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserReq.email,
        password: signinUserReq.password,
      );

      return const Right('Đăng nhập thành công');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'Không tìm thấy người dùng';
      } else if (e.code == 'invalid-credential') {
        message = 'Sai mật khẩu';
      }
      return Left(message);
    }
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    try {
      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserReq.email,
        password: createUserReq.password,
      );

      FirebaseFirestore.instance.collection('Users').doc(data.user?.uid).set({
        'name': createUserReq.fullName,
        'email': data.user?.email,
      });

      return const Right('Đăng ký thành công');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu yếu';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email đã tồn tại';
      }
      return Left(message);
    }
  }

  @override
  Future<Either> getUser() async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      var user =
          await firebaseFirestore
              .collection('Users')
              .doc(firebaseAuth.currentUser?.uid)
              .get();
              print('🔥 Dữ liệu Firestore raw: ${user.data()}');

      UserModel userModel = UserModel.fromJson(user.data()!);
      userModel.imageURL ??=
          firebaseAuth.currentUser?.photoURL ?? AppUrls.defaultImage;
      UserEntity userEntity = userModel.toEntity();
      return Right(userEntity);
    } catch (e) {
      return Left('xay ra loi trong hinh anh nguoi dung');
    }
  }

  @override
  Future<Either> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Right('Đăng xuất thành công');
    } catch (e) {
      return Left('Đăng xuất thất bại');
    }
  }

  @override
  Future<Either> updateName(String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Left('Chưa đăng nhập');
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({'name': newName});
      await user.updateDisplayName(newName);
      return const Right('Cập nhật tên thành công');
    } catch (e) {
      return Left('Cập nhật tên thất bại');
    }
  }

  @override
  Future<Either> updateImage(String imagePath) async {
    try {
      print('[updateImage] Start upload: $imagePath');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('[updateImage] No user logged in');
        return Left('Chưa đăng nhập');
      }
      final storageRef = FirebaseStorage.instance.ref().child('user_avatars/ [33m${user.uid}.jpg [39m');
      print('[updateImage] Storage ref: user_avatars/${user.uid}.jpg');
      final file = File(imagePath);
      print('[updateImage] File exists:  [33m${file.existsSync()} [39m');
      final uploadTask = await storageRef.putFile(file);
      print('[updateImage] Upload task state:  [33m${uploadTask.state} [39m');
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('[updateImage] Download URL: $downloadUrl');
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({'imageURL': downloadUrl});
      print('[updateImage] Firestore updated');
      await user.updatePhotoURL(downloadUrl);
      print('[updateImage] FirebaseAuth photoURL updated');
      return const Right('Cập nhật ảnh thành công');
    } catch (e, stack) {
      print('[updateImage] Error: $e');
      print('[updateImage] Stacktrace: $stack');
      return Left('Cập nhật ảnh thất bại: $e');
    }
  }
}
