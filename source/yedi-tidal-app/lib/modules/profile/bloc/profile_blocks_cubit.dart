import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/profile/model/profile_block_model.dart';
import 'package:yedi_app/modules/profile/service/profile_service.dart';
import 'package:yedi_app/util/models.dart';

enum ProfileBlocksStatus { loading, loaded }

class ProfileBlocksState implements Equatable {
  final List<ProfileBlockModel> blocks;
  final ProfileBlocksStatus status;
  final String? error;

  ProfileBlocksState({
    this.status = ProfileBlocksStatus.loading,
    this.blocks = const [],
    this.error,
  });

  ProfileBlocksState copyWith({
    ProfileBlocksStatus? status,
    List<ProfileBlockModel>? blocks,
    Wrapped<String?>? error,
  }) {
    return ProfileBlocksState(
      status: status ?? this.status,
      blocks: blocks ?? this.blocks,
      error: error is Wrapped ? error!.value : this.error,
    );
  }

  bool get isLoading => status == ProfileBlocksStatus.loading;
  bool get isLoaded => status == ProfileBlocksStatus.loaded;

  @override
  List<Object?> get props => [
        status,
        blocks,
        error,
        blocks,
      ];

  @override
  bool? get stringify => true;
}

class ProfileBlocksCubit extends Cubit<ProfileBlocksState> {
  final ProfileService profileService;

  ProfileBlocksCubit({required this.profileService})
      : super(ProfileBlocksState());

  Future loadBlocks() async {
    try {
      final blocks = await profileService.getBlocks();
      emit(state.copyWith(
        status: ProfileBlocksStatus.loaded,
        blocks: blocks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileBlocksStatus.loaded,
        error: Wrapped.value(e.toString()),
      ));
    }
  }
}
