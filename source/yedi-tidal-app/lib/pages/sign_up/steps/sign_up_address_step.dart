import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/address/address_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/address/address_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/address/address_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';

class SignUpAddressStep extends StatelessWidget {
  const SignUpAddressStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AddressBloc(
              signUpService: SignUpService(),
              dropdownService: DropdownService(),
              userType:
                  (context.read<SignUpPagesBloc>().state as SignUpPagesLoaded)
                      .userType,
            )..add(AddressInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child: BlocConsumer<AddressBloc, AddressState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == AddressStatus.success,
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
            if (state.status == AddressStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == AddressStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpAddressStepWidget();
          },
        ));
  }
}

class _SignUpAddressStepWidget extends StatefulWidget {
  const _SignUpAddressStepWidget();

  @override
  State<_SignUpAddressStepWidget> createState() =>
      _SignUpCreateProfileStepLoadedWidgetState();
}

class _SignUpCreateProfileStepLoadedWidgetState
    extends State<_SignUpAddressStepWidget> {
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _townCityController;
  late final TextEditingController _postcodeController;

  @override
  void initState() {
    super.initState();

    final formState = context.read<AddressBloc>().state;
    _line1Controller = TextEditingController(text: formState.line1);
    _line2Controller = TextEditingController(text: formState.line2);
    _townCityController = TextEditingController(text: formState.townCity);
    _postcodeController = TextEditingController(text: formState.postcode);

    _line1Controller.addListener(() => context
        .read<AddressBloc>()
        .add(AddressLine1Changed(_line1Controller.text)));
    _line2Controller.addListener(() => context
        .read<AddressBloc>()
        .add(AddressLine2Changed(_line2Controller.text)));
    _townCityController.addListener(() => context
        .read<AddressBloc>()
        .add(AddressTownCityChanged(_townCityController.text)));
    _postcodeController.addListener(() => context
        .read<AddressBloc>()
        .add(AddressPostcodeChanged(_postcodeController.text)));
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _postcodeController.dispose();
    _townCityController.dispose();
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

            return BlocBuilder<AddressBloc, AddressState>(
                builder: (context, formState) {
              return Column(
                children: [
                  StepPageTitle(title: currentPage.title),
                  VSpacer(20),
                  TextFieldInput(
                    label: "Address Line 1",
                    controller: _line1Controller,
                    errorText: formState.errors['line_1'],
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !formState.isSubmitting,
                  ),
                  TextFieldInput(
                    label: "Address Line 2",
                    controller: _line2Controller,
                    errorText: formState.errors['line_2'],
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    enabled: !formState.isSubmitting,
                  ),
                  TextFieldInput(
                    label: "Town/City",
                    controller: _townCityController,
                    errorText: formState.errors['town_city'],
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    enabled: !formState.isSubmitting,
                  ),
                  TextFieldInput(
                    label: "Postcode",
                    controller: _postcodeController,
                    errorText: formState.errors['postcode'],
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    enabled: !formState.isSubmitting,
                  ),
                  DropdownInput<String>(
                      items: formState.countryItems,
                      label: "Country",
                      errorText: formState.errors['country'],
                      value: formState.country,
                      onChanged: formState.isSubmitting
                          ? null
                          : (value) {
                              context
                                  .read<AddressBloc>()
                                  .add(AddressCountryChanged(value));
                            }),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: formState.isSubmitting
                                  ? null
                                  : () {
                                      context
                                          .read<AddressBloc>()
                                          .add(AddressSubmitted());
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
