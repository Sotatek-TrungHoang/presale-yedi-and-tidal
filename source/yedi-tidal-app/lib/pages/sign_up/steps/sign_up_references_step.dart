import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/references/references_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/references/references_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/references/references_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';

class SignUpReferencesStep extends StatelessWidget {
  const SignUpReferencesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ReferencesBloc(
              signUpService: SignUpService(),
              dropdownService: DropdownService(),
            )..add(ReferencesInitialised(
                (context.read<SignUpPagesBloc>().state as SignUpPagesLoaded)
                    .currentPage
                    .referencesRequired!,
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<ReferencesBloc, ReferencesState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == ReferencesStatus.success,
          listener: (context, state) {
            final updatedUser = state.updatedUser;
            if (updatedUser == null) {
              return;
            }

            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(updatedUser));
            context.read<SignUpPagesBloc>().add(SignUpPagesAddressCompleted());
          },
          builder: (context, state) {
            if (state.status == ReferencesStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == ReferencesStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpReferencesStepWidget();
          },
        ));
  }
}

class _SignUpReferencesStepWidget extends StatefulWidget {
  const _SignUpReferencesStepWidget();

  @override
  State<_SignUpReferencesStepWidget> createState() =>
      _SignUpCreateProfileStepLoadedWidgetState();
}

class _SignUpCreateProfileStepLoadedWidgetState
    extends State<_SignUpReferencesStepWidget> {
  late final List<TextEditingController> _nameControllers;
  late final List<TextEditingController> _emailControllers;
  late final List<TextEditingController> _telephoneControllers;
  late final int _referencesRequired;

  @override
  void initState() {
    super.initState();

    final formState = context.read<ReferencesBloc>().state;
    final pageState =
        context.read<SignUpPagesBloc>().state as SignUpPagesLoaded;

    final currentPage = pageState.currentPage;
    _referencesRequired = currentPage.referencesRequired!;

    _nameControllers = List.generate(
        _referencesRequired,
        (index) => TextEditingController(
            text: formState.references.elementAtOrNull(index)?.name ?? ""));
    _emailControllers = List.generate(
        _referencesRequired,
        (index) => TextEditingController(
            text: formState.references.elementAtOrNull(index)?.email ?? ""));
    _telephoneControllers = List.generate(
        _referencesRequired,
        (index) => TextEditingController(
            text:
                formState.references.elementAtOrNull(index)?.telephone ?? ""));

    for (var i = 0; i < _referencesRequired; i++) {
      _nameControllers[i].addListener(() => context
          .read<ReferencesBloc>()
          .add(ReferencesNameChanged(i, _nameControllers[i].text)));
      _emailControllers[i].addListener(() => context
          .read<ReferencesBloc>()
          .add(ReferencesEmailChanged(i, _emailControllers[i].text)));
      _telephoneControllers[i].addListener(() => context
          .read<ReferencesBloc>()
          .add(ReferencesTelephoneChanged(i, _telephoneControllers[i].text)));
    }
  }

  @override
  void dispose() {
    _nameControllers.map((controller) => controller.dispose());
    _emailControllers.map((controller) => controller.dispose());
    _telephoneControllers.map((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<SignUpPagesBloc, SignUpPagesState>(
          buildWhen: (previous, current) => false,
          builder: (context, state) {
            if (state is! SignUpPagesLoaded) {
              throw Exception("Unknown state: $state");
            }

            final currentPage = state.currentPage;

            return BlocBuilder<ReferencesBloc, ReferencesState>(
                builder: (context, formState) {
              return Column(
                children: [
                  StepPageTitle(title: currentPage.title),
                  VSpacer(20),
                  ...List.generate(_referencesRequired, (index) {
                    final referenceNo = index + 1;
                    return Column(
                      children: [
                        TextFieldInput(
                          label: "Reference $referenceNo Name",
                          controller: _nameControllers[index],
                          errorText: formState.errors['references.$index.name'],
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          enabled: !formState.isSubmitting,
                        ),
                        TextFieldInput(
                          label: "Reference $referenceNo Email",
                          controller: _emailControllers[index],
                          errorText:
                              formState.errors['references.$index.email'],
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !formState.isSubmitting,
                        ),
                        TextFieldInput(
                          label: "Reference $referenceNo Telephone",
                          controller: _telephoneControllers[index],
                          errorText:
                              formState.errors['references.$index.telephone'],
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.phone,
                          textInputAction: referenceNo == _referencesRequired
                              ? TextInputAction.done
                              : TextInputAction.next,
                          enabled: !formState.isSubmitting,
                        ),
                      ],
                    );
                  }),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: formState.isSubmitting
                                  ? null
                                  : () {
                                      context
                                          .read<ReferencesBloc>()
                                          .add(ReferencesSubmitted());
                                    },
                              child: Text(formState.isSubmitting
                                  ? "Processing..."
                                  : "Next Step"))),
                    ],
                  )
                ],
              );
            });
          },
        ));
  }
}
