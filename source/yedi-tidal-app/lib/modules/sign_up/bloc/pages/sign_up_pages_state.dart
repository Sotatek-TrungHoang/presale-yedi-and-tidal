import 'package:equatable/equatable.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/sign_up/models/sign_up_page_model.dart';
import 'package:yedi_app/util/models.dart';

sealed class SignUpPagesState {}

class SignUpPagesInitial extends SignUpPagesState {}

class SignUpPagesLoading extends SignUpPagesState {}

class SignUpPagesError extends SignUpPagesState {
  final String error;
  SignUpPagesError(this.error);
}

enum CancellingStatus { idle, cancelling, cancelledSignUp, cancelledPage }

class SignUpPagesLoaded extends SignUpPagesState implements Equatable {
  final List<SignUpPageModel> pages;
  final int currentPageIndex;
  final UserType userType;
  final bool completed;
  final CancellingStatus cancellingStatus;
  final String? cancellationError;

  SignUpPagesLoaded(
      {required this.pages,
      required this.currentPageIndex,
      required this.userType,
      this.completed = false,
      this.cancellingStatus = CancellingStatus.idle,
      this.cancellationError});

  SignUpPageModel get currentPage => pages[currentPageIndex];
  List<SignUpPageModel> get overviewPages =>
      pages.where((page) => page.showInOverview).toList();

  SignUpPagesLoaded copyWith(
      {List<SignUpPageModel>? pages,
      int? currentPageIndex,
      UserType? userType,
      bool? completed,
      CancellingStatus? cancellingStatus,
      Wrapped<String?>? cancellationError}) {
    return SignUpPagesLoaded(
        pages: pages ?? this.pages,
        currentPageIndex: currentPageIndex ?? this.currentPageIndex,
        userType: userType ?? this.userType,
        completed: completed ?? this.completed,
        cancellingStatus: cancellingStatus ?? this.cancellingStatus,
        cancellationError: cancellationError is Wrapped
            ? cancellationError!.value
            : this.cancellationError);
  }

  SignUpPagesLoaded changePage(int pageIndex) {
    return copyWith(currentPageIndex: pageIndex);
  }

  @override
  List<Object?> get props => [
        pages,
        currentPageIndex,
        userType,
        completed,
        cancellingStatus,
        cancellationError
      ];

  @override
  bool? get stringify => true;
}
