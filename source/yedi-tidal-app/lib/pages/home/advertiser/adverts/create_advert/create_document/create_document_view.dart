import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_state.dart';
import 'package:yedi_app/modules/common/cubits/add_document_cubit.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_document/create_document_content.dart';

class CreateDocumentView extends StatelessWidget {
  const CreateDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddDocumentCubit(),
      child: BlocListener<AddDocumentCubit, AddDocumentState>(
        listenWhen: (previous, current) =>
            current.status == AddDocumentStatus.submitted,
        listener: (context, state) {
          if (state.title.isNotEmpty && state.upload != null) {
            context.pop(CreateAdvertDocument(
                title: state.title, upload: state.upload!));
          }
        },
        child: CreateDocumentContent(),
      ),
    );
  }
}
