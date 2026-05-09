import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/data/models/auth/signin_user_req.dart';
import 'package:music_player/domain/repository/auth/auth.dart';
import 'package:music_player/service_locator.dart';

class SigninUseCase implements UseCase<Either,SigninUserReq> {
  @override
  Future<Either> call({SigninUserReq ? params}) {
      return sl<AuthRepository>().signin(params!);
  }

}