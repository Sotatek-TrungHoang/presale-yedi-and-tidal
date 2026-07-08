import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/profile/bloc/references_list_cubit.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class ApplicantReferencesContent extends StatelessWidget {
  const ApplicantReferencesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReferencesListCubit>().state;

    return RefreshIndicator(
      onRefresh: () => context.read<ReferencesListCubit>().loadReferences(),
      child: ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: state.references.length,
        separatorBuilder: (context, index) => const VSpacer(20),
        itemBuilder: (context, index) {
          final reference = state.references[index];
          return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(themeBorderRadius)),
                color: appColours.canvasBackground,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              reference.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(" (${reference.statusLabel})")
                          ],
                        ),
                        VSpacer(6),
                        Text(reference.email),
                        VSpacer(2),
                        Text(reference.telephone ?? ''),
                      ],
                    ),
                  ),
                  Icon(reference.icon)
                ],
              ));
        },
      ),
    );
  }
}
