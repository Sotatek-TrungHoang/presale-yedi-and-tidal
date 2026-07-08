import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/profile/bloc/update_address_cubit.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/page_error.dart';

class AddressForm extends StatelessWidget {
  const AddressForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateAddressCubit, UpdateAddressState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.isError) {
          return PageError(error: state.error ?? "An error occurred");
        }
        return _AddressFormLoaded();
      },
    );
  }
}

class _AddressFormLoaded extends StatefulWidget {
  const _AddressFormLoaded();

  @override
  State<_AddressFormLoaded> createState() => _AddressFormLoadedState();
}

class _AddressFormLoadedState extends State<_AddressFormLoaded> {
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _townCityController;
  late final TextEditingController _postcodeController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<UpdateAddressCubit>().state;
    _line1Controller = TextEditingController(text: formState.data['line_1']);
    _line2Controller = TextEditingController(text: formState.data['line_2']);
    _townCityController =
        TextEditingController(text: formState.data['town_city']);
    _postcodeController =
        TextEditingController(text: formState.data['postcode']);

    _line1Controller.addListener(() => context
        .read<UpdateAddressCubit>()
        .fieldUpdated('line_1', _line1Controller.text));
    _line2Controller.addListener(() => context
        .read<UpdateAddressCubit>()
        .fieldUpdated('line_2', _line2Controller.text));
    _townCityController.addListener(() => context
        .read<UpdateAddressCubit>()
        .fieldUpdated('town_city', _townCityController.text));
    _postcodeController.addListener(() => context
        .read<UpdateAddressCubit>()
        .fieldUpdated('postcode', _postcodeController.text));
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
    final formState = context.watch<UpdateAddressCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFieldInput(
            label: "Address Line 1",
            controller: _line1Controller,
            errorText: formState.errors['line_1'],
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            enabled: formState.isIdle,
          ),
          TextFieldInput(
            label: "Address Line 2",
            controller: _line2Controller,
            errorText: formState.errors['line_2'],
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enabled: formState.isIdle,
          ),
          TextFieldInput(
            label: "Town/City",
            controller: _townCityController,
            errorText: formState.errors['town_city'],
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enabled: formState.isIdle,
          ),
          TextFieldInput(
            label: "Postcode",
            controller: _postcodeController,
            errorText: formState.errors['postcode'],
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enabled: formState.isIdle,
          ),
          DropdownInput<String>(
              items: formState.countryItems,
              label: "Country",
              errorText: formState.errors['country'],
              value: formState.data['country'],
              onChanged: formState.isIdle
                  ? (value) => context
                      .read<UpdateAddressCubit>()
                      .fieldUpdated('country', value)
                  : null),
          ElevatedButton(
              onPressed: formState.isIdle
                  ? () => context.read<UpdateAddressCubit>().submit()
                  : null,
              child: Text(formState.isSubmitting
                  ? "Updating Address"
                  : "Update Address"))
        ],
      ),
    );
  }
}
