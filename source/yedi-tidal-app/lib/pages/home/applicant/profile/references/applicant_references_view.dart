import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/profile/bloc/references_list_cubit.dart';
import 'package:yedi_app/modules/profile/service/references_service.dart';
import 'package:yedi_app/pages/home/applicant/profile/references/applicant_references_content.dart';
import 'package:yedi_app/ui/page_error.dart';

class ApplicantReferencesView extends StatelessWidget {
  const ApplicantReferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('References'),
        ),
        body: BlocProvider(
          create: (context) => ReferencesListCubit(
              referencesService: context.read<ReferencesService>())
            ..loadReferences(),
          child: BlocBuilder<ReferencesListCubit, ReferencesListState>(
            buildWhen: (previous, current) =>
                previous.status != current.status ||
                previous.references.length != current.references.length,
            builder: (context, state) {
              switch (state.status) {
                case ReferencesListStatus.error:
                  return PageError(error: state.error ?? "An error occurred");
                case ReferencesListStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                default:
                  return ApplicantReferencesContent();
              }
            },
          ),
        ));
  }
}
