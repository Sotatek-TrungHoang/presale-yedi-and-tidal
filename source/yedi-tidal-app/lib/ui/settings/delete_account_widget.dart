import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_bloc.dart';
import 'package:yedi_app/modules/authentication/bloc/authentication_event.dart';
import 'package:yedi_app/ui/settings/cubits/delete_account_cubit.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';
import 'package:yedi_app/util/toast.dart';

class DeleteAccountWidget extends StatelessWidget {
  const DeleteAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.error != null) {
          showErrorToast(state.error!);
        } else if (state.status == DeleteAccountStatus.success) {
          showSuccessToast("Account deleted successfully");
          context.read<AuthenticationBloc>().add(AuthenticationLogoutPressed());
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appColours.error),
                    onPressed: state.canSubmit
                        ? () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text("Confirm Deletion"),
                                  content: Text(
                                      "Are you sure you want to delete your account? This action cannot be undone."),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: appColours.error),
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Close the dialog
                                        context
                                            .read<DeleteAccountCubit>()
                                            .submit();
                                      },
                                      child: Text("Delete Account"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
                    child: Text(state.isSubmitting
                        ? "Deleting Account..."
                        : "Delete Account")),
              ],
            ),
          ],
        );
      },
    );
  }
}
