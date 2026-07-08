import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/util/models.dart';

class SignUpPagesBloc extends Bloc<SignUpPagesEvent, SignUpPagesState> {
  final AuthenticationService _authenticationService;
  final SignUpService _signUpService;

  SignUpPagesBloc(
      AuthenticationService authenticationService, SignUpService signUpService)
      : _authenticationService = authenticationService,
        _signUpService = signUpService,
        super(SignUpPagesLoading()) {
    on<SignUpPagesInitialised>(_onSignUpPagesInitialised);
    on<SignUpPagesUserTypeSelected>(_onSignUpPagesUserTypeSelected);
    on<SignUpPagesOverviewCompleted>(_onSignUpPagesOverviewCompleted);
    on<SignUpPagesCreateProfileCompleted>(_onSignUpPagesCreateProfileCompleted);
    on<SignUpPagesComplianceCompleted>(_onSignUpPagesComplianceCompleted);
    on<SignUpPagesAddressCompleted>(_onSignUpPagesAddressCompleted);
    on<SignUpPagesQualificationsCompleted>(
        _onSignUpPagesQualificationsCompleted);
    on<SignUpPagesEvidenceCompleted>(_onSignUpPagesEvidenceCompleted);
    on<SignUpPagesDeclarationCompleted>(_onSignUpPagesDeclarationCompleted);
    on<SignUpPagesRightToWorkDeclarationCompleted>(
        _onSignUpPagesRightToWorkDeclarationCompleted);
    on<SignUpPagesComplianceCompletedCompleted>(
        _onSignUpPagesComplianceCompletedCompleted);
    on<SignUpPagesPreviousPagePressed>(_onSignUpPagesPreviousPagePressed);
    on<SignUpPagesCancelTapped>(_onSignUpPagesCancelTapped);
  }

  _onSignUpPagesInitialised(
      SignUpPagesInitialised event, Emitter<SignUpPagesState> emit) async {
    try {
      final user = event.user;
      if (user != null) {
        final result = await _signUpService.getPages(user.type);
        emit(SignUpPagesLoaded(
            pages: result.pages,
            currentPageIndex: result.currentPageIndex,
            userType: user.type));
      } else {
        emit(SignUpPagesInitial());
      }
    } on APIException catch (e) {
      emit(SignUpPagesError(e.message ?? "An error occurred"));
    } catch (e) {
      emit(SignUpPagesError(e.toString()));
    }
  }

  _onSignUpPagesUserTypeSelected(
    SignUpPagesUserTypeSelected event,
    Emitter<SignUpPagesState> emit,
  ) async {
    _authenticationService;

    try {
      emit(SignUpPagesLoading());
      final result = await _signUpService.getPages(event.userType);
      emit(SignUpPagesLoaded(
          pages: result.pages, currentPageIndex: 1, userType: event.userType));
    } on APIException catch (e) {
      emit(SignUpPagesError(e.message ?? "An error occurred"));
    } catch (e) {
      emit(SignUpPagesError(e.toString()));
    }
  }

  _onSignUpPagesOverviewCompleted(
    SignUpPagesOverviewCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesCreateProfileCompleted(
    SignUpPagesCreateProfileCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesComplianceCompleted(
    SignUpPagesComplianceCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesAddressCompleted(
    SignUpPagesAddressCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesQualificationsCompleted(
    SignUpPagesQualificationsCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesEvidenceCompleted(
    SignUpPagesEvidenceCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesDeclarationCompleted(
    SignUpPagesDeclarationCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesRightToWorkDeclarationCompleted(
    SignUpPagesRightToWorkDeclarationCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.changePage(state.currentPageIndex + 1));
    }
  }

  _onSignUpPagesComplianceCompletedCompleted(
    SignUpPagesComplianceCompletedCompleted event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded &&
        state.currentPageIndex < state.pages.length) {
      emit(state.copyWith(completed: true));
    }
  }

  _onSignUpPagesPreviousPagePressed(
    SignUpPagesPreviousPagePressed event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is SignUpPagesLoaded && state.currentPageIndex > 0) {
      emit(state.changePage(max(0, state.currentPageIndex - 1)));
    }
  }

  _onSignUpPagesCancelTapped(
    SignUpPagesCancelTapped event,
    Emitter<SignUpPagesState> emit,
  ) async {
    final state = this.state;
    if (state is! SignUpPagesLoaded) {
      return;
    }

    emit(state.copyWith(
        cancellingStatus: CancellingStatus.cancelling,
        cancellationError: Wrapped.value(null)));

    try {
      await _signUpService.cancelSignUp(event.userType);

      if (event.returnToLandingPage) {
        emit(
            state.copyWith(cancellingStatus: CancellingStatus.cancelledSignUp));
      } else {
        emit(state.copyWith(cancellingStatus: CancellingStatus.cancelledPage));
      }
    } on APIException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(state.copyWith(
            cancellingStatus: event.returnToLandingPage
                ? CancellingStatus.cancelledSignUp
                : CancellingStatus.cancelledPage));
        return;
      }

      emit(state.copyWith(
          cancellingStatus: CancellingStatus.idle,
          cancellationError: Wrapped.value(e.message ?? "An error occurred")));
    } catch (e) {
      emit(state.copyWith(cancellingStatus: CancellingStatus.idle));
    }
  }
}
