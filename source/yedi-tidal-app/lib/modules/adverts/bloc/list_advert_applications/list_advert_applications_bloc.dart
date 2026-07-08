import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_advert_applications/list_advert_applications_state.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/models.dart';

class ListAdvertApplicationsBloc
    extends Bloc<ListAdvertApplicationsEvent, ListAdvertApplicationsState> {
  final int advertId;
  final AdvertiserAdvertService advertService;

  ListAdvertApplicationsBloc(
      {required this.advertId, required this.advertService})
      : super(ListAdvertApplicationsState()) {
    on<ListAdvertApplicationsInitialised>(_onListAdvertApplicationsInitialised);
    on<ListAdvertApplicationsRefreshed>(_onListAdvertApplicationsRefreshed);
    on<ListAdvertApplicationsUpdateApplication>(
        _onListAdvertApplicationsUpdateApplication);
    on<ListAdvertApplicationsApplicationAccepted>(
        _onListAdvertApplicationsApplicationAccepted);
    on<ListAdvertApplicationsSetRefreshOnPop>(
        _onListAdvertApplicationsSetRefreshOnPop);

    on<ListAdvertApplicationsApplicantHearted>(
        _onListAdvertApplicationsApplicantHearted);
  }

  _onListAdvertApplicationsInitialised(ListAdvertApplicationsInitialised event,
      Emitter<ListAdvertApplicationsState> emit) async {
    emit(state.copyWith(status: ListAdvertApplicationsStatus.loading));
    await _fetchAdvertApplications(emit);
  }

  _onListAdvertApplicationsRefreshed(ListAdvertApplicationsRefreshed event,
      Emitter<ListAdvertApplicationsState> emit) async {
    emit(state.copyWith(status: ListAdvertApplicationsStatus.refreshing));
    await _fetchAdvertApplications(emit);
  }

  _onListAdvertApplicationsUpdateApplication(
      ListAdvertApplicationsUpdateApplication event,
      Emitter<ListAdvertApplicationsState> emit) async {
    final updatedApplication = event.updatedApplication;
    final updatedApplications = state.applications.map((application) {
      if (application.id == updatedApplication.id) {
        return updatedApplication;
      }
      return application;
    }).toList();

    emit(state.copyWith(applications: updatedApplications));
  }

  _onListAdvertApplicationsApplicationAccepted(
      ListAdvertApplicationsApplicationAccepted event,
      Emitter<ListAdvertApplicationsState> emit) async {
    final acceptedApplication = event.acceptedApplication;
    final updatedApplications = state.applications.map((application) {
      if (application.id == acceptedApplication.id) {
        return acceptedApplication;
      }

      if (application.status == ApplicationStatus.pending) {
        return application.copyWith(
            status: ApplicationStatus.declined,
            statusLabel: 'Declined',
            actionedAt: DateTime.now());
      }

      return application;
    }).toList();

    emit(state.copyWith(applications: updatedApplications));
  }

  _onListAdvertApplicationsSetRefreshOnPop(
      ListAdvertApplicationsSetRefreshOnPop event,
      Emitter<ListAdvertApplicationsState> emit) async {
    emit(state.copyWith(refreshAdvertOnPop: event.refreshOnPop));
  }

  _onListAdvertApplicationsApplicantHearted(
    ListAdvertApplicationsApplicantHearted event,
    Emitter<ListAdvertApplicationsState> emit,
  ) {
    final updatedApplications = state.applications.map((application) {
      if (application.applicantId == event.applicantId) {
        return application.copyWith(
            applicant: Wrapped.value(application.applicant!
                .copyWith(hearted: Wrapped.value(event.hearted))));
      }
      return application;
    }).toList();

    emit(state.copyWith(applications: updatedApplications));
  }

  _fetchAdvertApplications(Emitter<ListAdvertApplicationsState> emit) async {
    try {
      final advert = state.advert ?? await advertService.getAdvert(advertId);
      final applications = await retrieveApplications();
      emit(state.copyWith(
          advert: Wrapped.value(advert),
          applications: applications,
          status: ListAdvertApplicationsStatus.loaded,
          error: null));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: ListAdvertApplicationsStatus.error,
          error: Wrapped.value(e.message ?? "Something went wrong")));
    } catch (e) {
      emit(state.copyWith(
          status: ListAdvertApplicationsStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  Future<List<ApplicationModel>> retrieveApplications() async {
    return advertService.getAdvertApplications(advertId);
  }
}
