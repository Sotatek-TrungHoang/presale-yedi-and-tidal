import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/util/data_types.dart';

class DropdownService {
  late final ApiService _apiService;

  DropdownService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<List<Value<T>>> getDropdownOptions<T>(String code) async {
    final res = await _apiService.postData<Map<String, dynamic>>(
        'app/common/dropdowns', {"code": code, "search": "", "additional": []});

    return List.from(res.data!['data']).map((e) {
      return Value<T>(
        label: e['label'],
        value: e['value'] as T,
      );
    }).toList();
  }

  Future<List<Value<String>>> countries() async {
    return getDropdownOptions<String>('countries');
  }

  Future<List<Value<String>>> qualifications() async {
    return getDropdownOptions<String>('qualifications');
  }

  Future<List<Value<String>>> userTitles() async {
    return getDropdownOptions<String>('user_titles');
  }

  Future<List<Value<int>>> typesOfWork() async {
    return getDropdownOptions<int>('types_of_work');
  }

  Future<List<Value<int>>> jobRoles() async {
    return getDropdownOptions<int>('job_roles');
  }
}
