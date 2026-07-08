import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/advertiser_photo_upload/advertiser_photo_upload_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/advertiser_photo_upload/advertiser_photo_upload_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class AdvertiserPhotoUploadBloc
    extends Bloc<AdvertiserPhotoUploadEvent, AdvertiserPhotoUploadState> {
  final SignUpService signUpService;
  final DropdownService dropdownService;

  AdvertiserPhotoUploadBloc(
      {required this.signUpService, required this.dropdownService})
      : super(AdvertiserPhotoUploadState()) {
    on<AdvertiserPhotoUploadInitialised>(_onAdvertiserPhotoUploadInitialised);
    on<AdvertiserPhotoUploadPhotographChanged>(
        _onAdvertiserPhotoUploadPhotographChanged);
    on<AdvertiserPhotoUploadSubmitted>(_onAdvertiserPhotoUploadSubmitted);
  }

  _onAdvertiserPhotoUploadInitialised(AdvertiserPhotoUploadInitialised event,
      Emitter<AdvertiserPhotoUploadState> emit) {
    emit(state.copyWith(
      photograph: Wrapped.value(event.user?.advertiser?.photograph),
    ));
  }

  _onAdvertiserPhotoUploadPhotographChanged(
      AdvertiserPhotoUploadPhotographChanged event,
      Emitter<AdvertiserPhotoUploadState> emit) {
    emit(state.copyWith(photograph: Wrapped.value(event.value)));
  }

  _onAdvertiserPhotoUploadSubmitted(AdvertiserPhotoUploadSubmitted event,
      Emitter<AdvertiserPhotoUploadState> emit) async {
    try {
      final payload = state.payload;
      final response = await signUpService.submitAdvertiserPhotograph(payload);

      emit(state.copyWith(
          status: AdvertiserPhotoUploadStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIValidationException catch (e) {
      emit(state.copyWith(
          status: AdvertiserPhotoUploadStatus.waitingForSubmit,
          errors: e.errors,
          error: Wrapped.value(e.message ?? e.toString())));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: AdvertiserPhotoUploadStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: AdvertiserPhotoUploadStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
