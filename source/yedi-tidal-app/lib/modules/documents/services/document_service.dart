import 'dart:async';

import 'package:yedi_app/main.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/documents/models/contract_model.dart';
import 'package:yedi_app/modules/documents/models/invoice_model.dart';
import 'package:yedi_app/modules/documents/models/payslip_model.dart';

class DocumentService {
  late final ApiService _apiService;

  DocumentService() {
    _apiService = getIt.get<ApiService>();
  }

  Future<List<PayslipModel>> getPayslips() async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/applicant/payslips');

    return (res.data!['data'] as List)
        .map((e) => PayslipModel.fromJson(e))
        .toList();
  }

  Future<List<InvoiceModel>> getInvoices() async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/advertiser/invoices');

    return (res.data!['data'] as List)
        .map((e) => InvoiceModel.fromJson(e))
        .toList();
  }

  Future<List<ContractModel>> getAdvertiserContracts() async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/advertiser/contracts');

    return (res.data!['data'] as List)
        .map((e) => ContractModel.fromJson(e))
        .toList();
  }

  Future<List<ContractModel>> getApplicantContracts() async {
    final res = await _apiService
        .getData<Map<String, dynamic>>('app/applicant/contracts');

    return (res.data!['data'] as List)
        .map((e) => ContractModel.fromJson(e))
        .toList();
  }
}
