import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/api/api.dart';

class ApplicantAdvertService {
  late final ApiService _apiService;

  ApplicantAdvertService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<List<AdvertModel>> listAdvertsByType(AdvertType type) async {
    final res = await _apiService.getData<Map<String, dynamic>>(
        'app/applicant/adverts',
        queryParameters: {'type': type.name});

    final adverts = List.from(res.data!['data'])
        .map((data) => AdvertModel.fromJson(data))
        .toList();
    return adverts;
  }

  Future<List<AdvertModel>> listConfirmedBookings() async {
    final res = await _apiService.getData<Map<String, dynamic>>(
      'app/applicant/bookings/confirmed',
    );

    final adverts = List.from(res.data!['data'])
        .map((data) => AdvertModel.fromJson(data))
        .toList();
    return adverts;
  }

  Future<List<AdvertModel>> listAppliedTo() async {
    final res = await _apiService.getData<Map<String, dynamic>>(
      'app/applicant/bookings/applied-to',
    );

    final adverts = List.from(res.data!['data'])
        .map((data) => AdvertModel.fromJson(data))
        .toList();
    return adverts;
  }

  Future<AdvertModel> getAdvert(int id) async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/applicant/adverts/$id');

    return AdvertModel.fromJson(res.data!['data']);
  }

  Future<AdvertModel> apply(int id) async {
    final res = await _apiService
        .postData<Map<String, dynamic>>('app/applicant/adverts/$id/apply');

    return AdvertModel.fromJson(res.data!['data']);
  }

  Future<AdvertModel> cancelApplication(int advertId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/applicant/adverts/$advertId/cancel-application');

    return AdvertModel.fromJson(res.data!['data']);
  }
}
