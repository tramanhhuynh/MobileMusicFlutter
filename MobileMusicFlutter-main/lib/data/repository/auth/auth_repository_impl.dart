import 'package:dartz/dartz.dart';
import 'package:music_player/data/models/auth/create_user_req.dart';
import 'package:music_player/data/models/auth/signin_user_req.dart';
import 'package:music_player/data/sources/auth/auth_firebase_service.dart';
import 'package:music_player/domain/repository/auth/auth.dart';
import 'package:music_player/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signin(SigninUserReq signinUserReq) async {
       return await sl<AuthFirebaseService>().signin(signinUserReq);
  }

  @override
  Future<Either> signup(CreateUserReq createUserReq) async {
    return await sl<AuthFirebaseService>().signup(createUserReq);
  }
  
  @override
  Future<Either> getUser() async {
    return await sl<AuthFirebaseService>().getUser();
  }

  @override
  Future<Either> signOut() async {
    return await sl<AuthFirebaseService>().signOut();
  }

  @override
  Future<Either> updateName(String newName) async {
    return await sl<AuthFirebaseService>().updateName(newName);
  }

  @override
  Future<Either> updateImage(String imagePath) async {
    return await sl<AuthFirebaseService>().updateImage(imagePath);
  }
}