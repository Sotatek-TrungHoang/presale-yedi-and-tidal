import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yedi_app/modules/common/cubits/add_document_cubit.dart';
import 'package:yedi_app/ui/inputs/file_upload_input.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';

class CreateDocumentContent extends StatefulWidget {
  const CreateDocumentContent({super.key});

  @override
  State<CreateDocumentContent> createState() => _CreateDocumentContentState();
}

class _CreateDocumentContentState extends State<CreateDocumentContent> {
  final _titleController = TextEditingController();

  @override
  initState() {
    super.initState();
    _titleController.addListener(
        () => context.read<AddDocumentCubit>().setTitle(_titleController.text));
  }

  @override
  dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<AddDocumentCubit, AddDocumentState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldInput(
                  label: "Document Title",
                  controller: _titleController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                ),
                FileUploadInput(
                  buttonText: "Upload Document",
                  uploadModel: state.upload,
                  onUploaded: (upload) {
                    context.read<AddDocumentCubit>().setUpload(upload);
                  },
                  useFilePicker: true,
                  icon: Icons.file_upload,
                ),
                Divider(
                  height: 50,
                ),
                ElevatedButton(
                    onPressed: state.canSubmit
                        ? () {
                            context
                                .read<AddDocumentCubit>()
                                .addDocumentTapped();
                          }
                        : null,
                    child: Text("Add Document"))
              ],
            );
          },
        ));
  }
}
