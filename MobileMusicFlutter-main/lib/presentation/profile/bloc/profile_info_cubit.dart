import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/domain/usecases/auth/get_user.dart';
import 'package:music_player/presentation/profile/bloc/profile_info_state.dart';
import 'package:music_player/service_locator.dart';
import 'package:music_player/domain/repository/auth/auth.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit() : super(ProfileInfoLoading());

  Future<void> getUser() async {
    print('[ProfileInfoCubit] getUser');
    var user = await sl<GetUserUseCase>().call();

    user.fold(
      (l) {
        print('[ProfileInfoCubit] getUser failed');
        if (!isClosed) emit(ProfileInfoFailure());
      },
      (userEntity) {
        print('[ProfileInfoCubit] getUser success: ' + userEntity.toString());
        if (!isClosed) emit(ProfileInfoLoaded(userEntity: userEntity));
      },
    );
  }

  Future<void> updateName(String newName) async {
    if (!isClosed) emit(ProfileInfoLoading());
    var result = await sl<AuthRepository>().updateName(newName);
    result.fold(
      (l) {
        if (!isClosed) emit(ProfileInfoFailure());
      },
      (r) async {
        await getUser();
      },
    );
  }

  Future<void> updateImage(String imagePath) async {
    print('[ProfileInfoCubit] updateImage: $imagePath');
    if (!isClosed) emit(ProfileInfoLoading());
    var result = await sl<AuthRepository>().updateImage(imagePath);
    result.fold(
      (l) {
        print('[ProfileInfoCubit] updateImage failed: $l');
        if (!isClosed) emit(ProfileInfoFailure());
      },
      (r) async {
        print('[ProfileInfoCubit] updateImage success, reload user');
        await getUser();
      },
    );
  }

  Future<void> signOut() async {
    await sl<AuthRepository>().signOut();
  }
}
