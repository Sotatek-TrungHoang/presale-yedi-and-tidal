import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/modules/profile/bloc/update_advertiser_profile_cubit.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/photo_upload_widget.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/strings.dart';

class AdvertiserUpdateProfileContent extends StatefulWidget {
  const AdvertiserUpdateProfileContent({super.key});

  @override
  State<AdvertiserUpdateProfileContent> createState() =>
      AdvertiserUpdateProfileContentState();
}

class AdvertiserUpdateProfileContentState
    extends State<AdvertiserUpdateProfileContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<UpdateAdvertiserProfileCubit>().state;
    _nameController = TextEditingController(text: formState.data['name']);
    _emailController = TextEditingController(text: formState.data['email']);
    _telephoneController =
        TextEditingController(text: formState.data['telephone']);
    _bioController = TextEditingController(text: formState.data['bio']);
    _additionalInfoController =
        TextEditingController(text: formState.data['additional_info']);

    _nameController.addListener(() => context
        .read<UpdateAdvertiserProfileCubit>()
        .fieldUpdated('name', _nameController.text));
    _emailController.addListener(() => context
        .read<UpdateAdvertiserProfileCubit>()
        .fieldUpdated('email', _emailController.text));
    _telephoneController.addListener(() => context
        .read<UpdateAdvertiserProfileCubit>()
        .fieldUpdated('telephone', _telephoneController.text));
    _bioController.addListener(() => context
        .read<UpdateAdvertiserProfileCubit>()
        .fieldUpdated('bio', _bioController.text));
    _additionalInfoController.addListener(() => context
        .read<UpdateAdvertiserProfileCubit>()
        .fieldUpdated('additional_info', _additionalInfoController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _bioController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = context.watch<UpdateAdvertiserProfileCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFieldInput(
            label:
                "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Name",
            controller: _nameController,
            enabled: formState.isIdle,
            errorText: formState.errors['name'],
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          TextFieldInput(
            label:
                "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Email",
            controller: _emailController,
            enabled: formState.isIdle,
            errorText: formState.errors['email'],
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
          TextFieldInput(
            label:
                "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Telephone",
            controller: _telephoneController,
            enabled: formState.isIdle,
            errorText: formState.errors['telephone'],
            keyboardType: TextInputType.phone,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
          TextFieldInput(
            label: "Bio",
            controller: _bioController,
            enabled: formState.isIdle,
            errorText: formState.errors['bio'],
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            maxLines: 8,
          ),
          TextFieldInput(
            label: "Additional Info",
            controller: _additionalInfoController,
            enabled: formState.isIdle,
            errorText: formState.errors['additional_info'],
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            maxLines: 8,
          ),
          PhotoUploadWidget(
              label:
                  "${AppLocalizations.of(context)!.advertiser.toTitleCase()} Photo",
              errorText: formState.errors['photograph_id'],
              uploadModel: formState.photograph,
              onUploaded: (uploadModel) => context
                  .read<UpdateAdvertiserProfileCubit>()
                  .photographUpdated(uploadModel),
              incompleteButtonText:
                  "Update ${AppLocalizations.of(context)!.advertiser.toTitleCase()} Photo",
              completeButtonText:
                  "Update ${AppLocalizations.of(context)!.advertiser.toTitleCase()} Photo"),
          Divider(
            height: 50,
          ),
          ElevatedButton(
              onPressed: formState.isIdle
                  ? () => context.read<UpdateAdvertiserProfileCubit>().submit()
                  : null,
              child: Text(formState.isSubmitting
                  ? "Updating Profile"
                  : "Update Profile")),
          if (formState.error != null) ...[
            VSpacer(20),
            Text(
              formState.error!,
              style: TextStyle(color: appColours.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
