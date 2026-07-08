import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/modules/common/services/dropdown_service.dart';
import 'package:yedi_app/modules/sign_up/bloc/advertiser_photo_upload/advertiser_photo_upload_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/advertiser_photo_upload/advertiser_photo_upload_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/advertiser_photo_upload/advertiser_photo_upload_state.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_bloc.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_event.dart';
import 'package:yedi_app/modules/sign_up/bloc/pages/sign_up_pages_state.dart';
import 'package:yedi_app/modules/sign_up/services/sign_up_service.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/photo_upload_widget.dart';
import 'package:yedi_app/pages/sign_up/steps/ui/step_page_title.dart';
import 'package:yedi_app/ui/page_error.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:yedi_app/util/strings.dart';

class SignUpAdvertiserPhotoUploadStep extends StatelessWidget {
  const SignUpAdvertiserPhotoUploadStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AdvertiserPhotoUploadBloc(
              signUpService: SignUpService(),
              dropdownService: DropdownService(),
            )..add(AdvertiserPhotoUploadInitialised(
                context.read<AuthenticationBloc>().state.user)),
        child:
            BlocConsumer<AdvertiserPhotoUploadBloc, AdvertiserPhotoUploadState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == AdvertiserPhotoUploadStatus.success,
          listener: (context, state) {
            final updatedUser = state.updatedUser;
            if (updatedUser == null) {
              return;
            }

            context
                .read<AuthenticationBloc>()
                .add(ReplaceUserModel(updatedUser));
            context
                .read<SignUpPagesBloc>()
                .add(SignUpPagesCreateProfileCompleted());
          },
          builder: (context, state) {
            if (state.status == AdvertiserPhotoUploadStatus.error) {
              return PageError(
                error: state.error ?? "An error occurred",
              );
            }
            return _SignUpAdvertiserPhotoUploadStepWidget();
          },
        ));
  }
}

class _SignUpAdvertiserPhotoUploadStepWidget extends StatelessWidget {
  const _SignUpAdvertiserPhotoUploadStepWidget();

  @override
  Widget build(BuildContext context) {
    final state = context.read<SignUpPagesBloc>().state;
    final user = context.read<AuthenticationBloc>().state.user;
    if (state is! SignUpPagesLoaded) {
      throw Exception("Unknown state: $state");
    }

    final currentPage = state.currentPage;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child:
            BlocBuilder<AdvertiserPhotoUploadBloc, AdvertiserPhotoUploadState>(
                builder: (context, formState) {
          return Column(
            children: [
              StepPageTitle(title: currentPage.title),
              VSpacer(20),
              PhotoUploadWidget(
                incompleteButtonText:
                    "Upload ${AppLocalizations.of(context)!.advertiser.toTitleCase()} Photo",
                completeButtonText:
                    "Upload ${AppLocalizations.of(context)!.advertiser.toTitleCase()} Photo",
                uploadFromGoogleName: user?.advertiser?.name,
                uploadFromGooglePostcode: user?.advertiser?.address?.postcode,
                errorText: formState.errors['photograph_id'],
                uploadModel: formState.photograph,
                onUploaded: (uploadModel) {
                  context
                      .read<AdvertiserPhotoUploadBloc>()
                      .add(AdvertiserPhotoUploadPhotographChanged(uploadModel));
                },
              ),
              VSpacer(20),
              if (formState.error != null) ...[
                Text(
                  formState.error!,
                  style: TextStyle(color: appColours.error),
                  textAlign: TextAlign.center,
                ),
                VSpacer(20),
              ],
              VSpacer(36),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: !formState.canSubmit
                              ? null
                              : () {
                                  context
                                      .read<AdvertiserPhotoUploadBloc>()
                                      .add(AdvertiserPhotoUploadSubmitted());
                                },
                          child: Text(formState.isSubmitting
                              ? "Processing..."
                              : "Next Step"))),
                ],
              ),
            ],
          );
        }));
  }
}
