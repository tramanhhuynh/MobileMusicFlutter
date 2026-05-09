import 'package:dartz/dartz.dart';
import 'package:music_player/core/usecase/usecase.dart';
import 'package:music_player/data/models/auth/create_user_req.dart';
import 'package:music_player/domain/repository/auth/auth.dart';
import 'package:music_player/service_locator.dart';

class SignupUseCase implements UseCase<Either,CreateUserReq> {
  @override
  Future<Either> call({CreateUserReq ? params}) {
      return sl<AuthRepository>().signup(params!);
  }

}