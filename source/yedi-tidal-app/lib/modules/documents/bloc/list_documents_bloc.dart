import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/api/api_exceptions.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_event.dart';
import 'package:yedi_app/modules/documents/bloc/list_documents_state.dart';
import 'package:yedi_app/modules/documents/models/contract_model.dart';
import 'package:yedi_app/modules/documents/models/invoice_model.dart';
import 'package:yedi_app/modules/documents/models/payslip_model.dart';
import 'package:yedi_app/modules/documents/services/document_service.dart';
import 'package:yedi_app/util/models.dart';

abstract class ListDocumentsBloc<T>
    extends Bloc<ListDocumentsEvent, ListDocumentsState<T>> {
  ListDocumentsBloc({required this.documentService})
      : super(ListDocumentsState()) {
    on<ListDocumentsInitialised>(_onListDocumentsInitialised);
    on<ListDocumentsRefreshed>(_onListDocumentsRefreshed);
  }

  final DocumentService documentService;

  _onListDocumentsInitialised(ListDocumentsInitialised event,
      Emitter<ListDocumentsState<T>> emit) async {
    emit(state.copyWith(status: ListDocumentsStatus.loading));
    await _fetchDocuments(emit);
  }

  _onListDocumentsRefreshed(
      ListDocumentsRefreshed event, Emitter<ListDocumentsState<T>> emit) async {
    emit(state.copyWith(status: ListDocumentsStatus.refreshing));
    await _fetchDocuments(emit);
  }

  _fetchDocuments(Emitter<ListDocumentsState<T>> emit) async {
    try {
      final documents = await retrieveDocuments();
      emit(state.copyWith(
          documents: documents,
          status: ListDocumentsStatus.loaded,
          error: null));
    } on APIException catch (e) {
      emit(state.copyWith(
          status: ListDocumentsStatus.error,
          error: Wrapped.value(e.message ?? "Something went wrong")));
    } catch (e) {
      emit(state.copyWith(
          status: ListDocumentsStatus.error,
          error: Wrapped.value(e.toString())));
    }
  }

  Future<List<T>> retrieveDocuments() async {
    throw UnimplementedError();
  }
}

class ListPayslipsBloc extends ListDocumentsBloc<PayslipModel> {
  ListPayslipsBloc({required super.documentService});

  @override
  Future<List<PayslipModel>> retrieveDocuments() async {
    return documentService.getPayslips();
  }
}

class ListInvoicesBloc extends ListDocumentsBloc<InvoiceModel> {
  ListInvoicesBloc({required super.documentService});

  @override
  Future<List<InvoiceModel>> retrieveDocuments() async {
    return documentService.getInvoices();
  }
}

class ListAdvertiserContractsBloc extends ListDocumentsBloc<ContractModel> {
  ListAdvertiserContractsBloc({required super.documentService});

  @override
  Future<List<ContractModel>> retrieveDocuments() async {
    return documentService.getAdvertiserContracts();
  }
}

class ListApplicantContractsBloc extends ListDocumentsBloc<ContractModel> {
  ListApplicantContractsBloc({required super.documentService});

  @override
  Future<List<ContractModel>> retrieveDocuments() async {
    return documentService.getApplicantContracts();
  }
}
