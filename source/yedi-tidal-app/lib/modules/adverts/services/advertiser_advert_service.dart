import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/modules/adverts/models/application_model.dart';
import 'package:yedi_app/modules/api/api.dart';

class AdvertiserAdvertService {
  late final ApiService _apiService;

  AdvertiserAdvertService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<List<AdvertModel>> listAdvertsByType(AdvertType type) async {
    final res = await _apiService.getData<Map<String, dynamic>>(
        'app/advertiser/adverts',
        queryParameters: {'type': type.name});

    final adverts = List.from(res.data!['data'])
        .map((data) => AdvertModel.fromJson(data))
        .toList();
    return adverts;
  }

  Future<AdvertModel> getAdvert(int id) async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/advertiser/adverts/$id');

    return AdvertModel.fromJson(res.data!['data']);
  }

  Future<List<ApplicationModel>> getApplications(
      {ApplicationStatus? applicationStatus}) async {
    final res = await _apiService.getData<Map<String, dynamic>>(
        'app/advertiser/applications',
        queryParameters: {
          'status': applicationStatus?.name,
        });

    return List.from(res.data!['data']).map((data) {
      return ApplicationModel.fromJson(data);
    }).toList();
  }

  Future<List<ApplicationModel>> getAdvertApplications(int advertId) async {
    final res = await _apiService.getData<Map<String, dynamic>>(
        'app/advertiser/adverts/$advertId/applications');

    return List.from(res.data!['data']).map((data) {
      return ApplicationModel.fromJson(data);
    }).toList();
  }

  Future<ApplicationModel> declineApplication(int applicationId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/applications/$applicationId/decline');

    return ApplicationModel.fromJson(res.data!['data']);
  }

  Future<ApplicationModel> acceptApplication(int applicationId) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/applications/$applicationId/accept');

    return ApplicationModel.fromJson(res.data!['data']);
  }

  Future<ApplicationModel> rateApplication(
      int applicationId, int rating) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/applications/$applicationId/rate', {"rating": rating});

    return ApplicationModel.fromJson(res.data!['data']);
  }

  Future<AdvertModel> createAdvert(Map<String, dynamic> data) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/advertiser/adverts', data);

    return AdvertModel.fromJson(res.data!['data']);
  }

  Future delete(int advertId) async {
    await _apiService.deleteData('app/advertiser/adverts/$advertId');
    return;
  }
}
