import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/sign_up/bloc/complete_account/complete_account_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/complete_account/complete_account_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class CompleteAccountBloc
    extends Bloc<CompleteAccountEvent, CompleteAccountState> {
  final SignUpService signUpService;
  final UserType userType;

  CompleteAccountBloc({
    required this.signUpService,
    required this.userType,
  }) : super(CompleteAccountState()) {
    on<CompleteAccountSubmitted>(_onCompleteAccountSubmitted);
  }

  _onCompleteAccountSubmitted(CompleteAccountSubmitted event,
      Emitter<CompleteAccountState> emit) async {
    emit(state.copyWith(
        status: CompleteAccountStatus.submitting,
        error: Wrapped.value(null),
        updatedUser: Wrapped.value(null)));

    try {
      final response = userType == UserType.applicant
          ? await signUpService.completeApplicantSignUp()
          : await signUpService.completeAdvertiserSignUp();

      emit(state.copyWith(
          status: CompleteAccountStatus.success,
          updatedUser: Wrapped.value(response),
          error: Wrapped.value(null)));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: CompleteAccountStatus.waitingForSubmit,
          error: Wrapped.value(e.message ?? e.toString())));
    } catch (e) {
      emit(state.copyWith(
          status: CompleteAccountStatus.waitingForSubmit,
          error: Wrapped.value(e.toString())));
    }
  }
}
