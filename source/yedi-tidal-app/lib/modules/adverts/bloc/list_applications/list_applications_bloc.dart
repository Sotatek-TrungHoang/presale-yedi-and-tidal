import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_event.dart';
import 'package:yedi_app/modules/adverts/bloc/list_applications/list_applications_state.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/adverts/services/advertiser_advert_service.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/util/models.dart';

abstract class ListApplicationsBloc
    extends Bloc<ListApplicationsEvent, ListApplicationsState> {
  final AdvertiserAdvertService advertService;
  final ApplicationStatus applicationStatus;

  ListApplicationsBloc(
      {required this.advertService, required this.applicationStatus})
      : super(ListApplicationsState()) {
    on<ListApplicationsInitialised>(_onListApplicationsInitialised);
    on<ListApplicationsRefreshed>(_onListApplicationsRefreshed);
    on<ListApplicationsUpdateApplication>(_onListApplicationsUpdateApplication);
    on<ListApplicationsApplicationAccepted>(
        _onListApplicationsApplicationAccepted);
    on<ListApplicationsApplicantHearted>(_onListApplicationsApplicantHearted);
  }

  _onListApplicationsInitialised(ListApplicationsInitialised event,
      Emitter<ListApplicationsState> emit) async {
    emit(state.copyWith(status: ListApplicationsStatus.loading));
    await _fetchApplications(emit);
  }

  _onListApplicationsRefreshed(ListApplicationsRefreshed event,
      Emitter<ListApplicationsState> emit) async {
    emit(state.copyWith(status: ListApplicationsStatus.refreshing));
    await _fetchApplications(emit);
  }

  _onListApplicationsUpdateApplication(ListApplicationsUpdateApplication event,
      Emitter<ListApplicationsState> emit) async {
    final updatedApplication = event.updatedApplication;
    final updatedApplications = state.applications.map((application) {
      if (application.id == updatedApplication.id) {
        return updatedApplication;
      }
      return application;
    }).toList();

    emit(state.copyWith(applications: updatedApplications));
  }

  _onListApplicationsApplicationAccepted(
      ListApplicationsApplicationAccepted event,
      Emitter<ListApplicationsState> emit) async {
    throw UnimplementedError();
  }

  _onListApplicationsApplicantHearted(
    ListApplicationsApplicantHearted event,
    Emitter<ListApplicationsState> emit,
  ) {
    final applicantId = event.applicantId;
    final hearted = event.hearted;

    final updatedApplications = state.applications.map((application) {
      if (application.applicantId == applicantId) {
        return application.copyWith(
            applicant: Wrapped.value(application.applicant
                ?.copyWith(hearted: Wrapped.value(hearted))));
      }
      return application;
    }).toList();

    emit(state.copyWith(applications: updatedApplications));
  }

  _fetchApplications(Emitter<ListApplicationsState> emit) async {
    try {
      final applications = await retrieveApplications();
      emit(state.copyWith(
          applications: applications,
          status: ListApplicationsStatus.loaded,
          error: null));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: ListApplicationsStatus.error,
          error: Wrapped.value(e.message ?? "Something went wrong")));
    } catch (e) {
      emit(state.copyWith(
          status: ListApplicationsStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  Future<List<ApplicationModel>> retrieveApplications() async {
    return advertService.getApplications(applicationStatus: applicationStatus);
  }
}

class ListPendingApplicationsBloc extends ListApplicationsBloc {
  ListPendingApplicationsBloc({required super.advertService})
      : super(applicationStatus: ApplicationStatus.pending);

  @override
  _onListApplicationsApplicationAccepted(
      ListApplicationsApplicationAccepted event,
      Emitter<ListApplicationsState> emit) async {
    final acceptedApplication = event.acceptedApplication;
    final updatedApplications = state.applications
        .where((application) =>
            application.advertId != acceptedApplication.advertId)
        .toList();

    emit(state.copyWith(applications: updatedApplications));
  }
}

class ListAcceptedApplicationsBloc extends ListApplicationsBloc {
  ListAcceptedApplicationsBloc({required super.advertService})
      : super(applicationStatus: ApplicationStatus.accepted);
}
