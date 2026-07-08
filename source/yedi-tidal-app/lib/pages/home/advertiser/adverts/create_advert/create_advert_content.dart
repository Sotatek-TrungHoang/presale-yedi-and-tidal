import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_bloc.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_event.dart';
import 'package:yedi_app/modules/adverts/bloc/create_advert/create_advert_state.dart';
import 'package:yedi_app/modules/adverts/models/advert_model.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_document/create_document_page.dart';
import 'package:yedi_app/ui/adverts/advert_document_tile.dart';
import 'package:yedi_app/ui/inputs/date_input.dart';
import 'package:yedi_app/ui/inputs/dropdown_input.dart';
import 'package:yedi_app/ui/inputs/input_label.dart';
import 'package:yedi_app/ui/inputs/text_field_input.dart';
import 'package:yedi_app/ui/inputs/time_input.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/util/dates.dart';

class CreateAdvertContent extends StatefulWidget {
  const CreateAdvertContent({super.key});

  @override
  State<CreateAdvertContent> createState() => _CreateAdvertContentState();
}

class _CreateAdvertContentState extends State<CreateAdvertContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _shiftStartTimeController =
      TextEditingController();
  final TextEditingController _shiftEndTimeController = TextEditingController();
  final TextEditingController _applyByDateController = TextEditingController();
  final TextEditingController _applyByTimeController = TextEditingController();

  final TextEditingController _dayToDayActiveMinutesController =
      TextEditingController();

  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPositionController =
      TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactTelephoneController =
      TextEditingController();

  final TextEditingController _payRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertTitleChanged(_titleController.text)));

    _descriptionController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertDescriptionChanged(_descriptionController.text)));

    _dayToDayActiveMinutesController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertDayToDayActiveMinutesChanged(
            _dayToDayActiveMinutesController.text)));

    _contactNameController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertContactNameChanged(_contactNameController.text)));
    _contactPositionController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertContactPositionChanged(
            _contactPositionController.text)));
    _contactEmailController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertContactEmailChanged(_contactEmailController.text)));
    _contactTelephoneController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertContactTelephoneChanged(
            _contactTelephoneController.text)));

    _payRateController.addListener(() => context
        .read<CreateAdvertBloc>()
        .add(CreateAdvertPayRateChanged(_payRateController.text)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _shiftStartTimeController.dispose();
    _shiftEndTimeController.dispose();
    _applyByDateController.dispose();
    _applyByTimeController.dispose();
    _dayToDayActiveMinutesController.dispose();
    _contactNameController.dispose();
    _contactPositionController.dispose();
    _contactEmailController.dispose();
    _contactTelephoneController.dispose();
    _payRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAdvertBloc, CreateAdvertState>(
      builder: (context, formState) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldInput(
                  label: "Title",
                  controller: _titleController,
                  enabled: !formState.isSubmitting,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  errorText: formState.errors['title'],
                ),
                TextFieldInput(
                  label: "Description",
                  controller: _descriptionController,
                  enabled: !formState.isSubmitting,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLines: 5,
                  errorText: formState.errors['description'],
                ),
                Divider(
                  height: 50,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DateInput(
                        label: "Date of First Shift",
                        enabled: !formState.isSubmitting,
                        controller: _startDateController,
                        initialDate: formState.startsAt,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                        onChanged: (date) {
                          context
                              .read<CreateAdvertBloc>()
                              .add(CreateAdvertStartsAtChanged(date));
                        },
                        errorText: formState.errors['starts_at'],
                      ),
                    ),
                    HSpacer(20),
                    Expanded(
                      child: DateInput(
                        label: "Date of Last Shift",
                        enabled: !formState.isSubmitting,
                        controller: _endDateController,
                        initialDate: formState.endsAt,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                        onChanged: (date) {
                          context
                              .read<CreateAdvertBloc>()
                              .add(CreateAdvertEndsAtChanged(date));
                        },
                        errorText: formState.errors['ends_at'],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TimeInput(
                        label: "Shift Start Time",
                        enabled: !formState.isSubmitting,
                        controller: _shiftStartTimeController,
                        initialTime: formState.shiftStartsAt,
                        onChanged: (time) {
                          context
                              .read<CreateAdvertBloc>()
                              .add(CreateAdvertShiftStartsAtChanged(time));
                        },
                        errorText: formState.errors['shift_start_time'],
                      ),
                    ),
                    HSpacer(20),
                    Expanded(
                      child: TimeInput(
                        label: "Shift End Time",
                        enabled: !formState.isSubmitting,
                        controller: _shiftEndTimeController,
                        initialTime: formState.shiftEndsAt,
                        onChanged: (time) {
                          context
                              .read<CreateAdvertBloc>()
                              .add(CreateAdvertShiftEndsAtChanged(time));
                        },
                        errorText: formState.errors['shift_end_time'],
                      ),
                    ),
                  ],
                ),
                if (formState.shifts != null &&
                    formState.shifts!.isNotEmpty) ...[
                  Text(
                    "The following ${formState.shifts!.length == 1 ? 'shift' : 'shifts'} will be created:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  VSpacer(2),
                  for (final shift in formState.shifts!)
                    if (shift['starts_at']!.isSameDay(shift['ends_at']!))
                      Text(
                          "${shift['starts_at']!.formatDateTime(format: "EEE d MMM")} from ${shift['starts_at']!.formatDateTime(format: "HH:mm")} to ${shift['ends_at']!.formatDateTime(format: "HH:mm")}")
                    else
                      Text(
                          "${shift['starts_at']!.formatDateTime(format: "EEE d MMM 'at' HH:mm")} to ${shift['ends_at']!.formatDateTime(format: "EEE d MMM 'at' HH:mm")}"),
                ],
                Divider(
                  height: 50,
                ),
                TextFieldInput(
                  label: "Contact Name",
                  controller: _contactNameController,
                  enabled: !formState.isSubmitting,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  errorText: formState.errors['contact_name'],
                ),
                TextFieldInput(
                  label: "Contact Position",
                  controller: _contactPositionController,
                  enabled: !formState.isSubmitting,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  errorText: formState.errors['contact_position'],
                ),
                TextFieldInput(
                  label: "Contact Email",
                  controller: _contactEmailController,
                  enabled: !formState.isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  errorText: formState.errors['contact_email'],
                ),
                TextFieldInput(
                  label: "Contact Telephone",
                  controller: _contactTelephoneController,
                  enabled: !formState.isSubmitting,
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                  errorText: formState.errors['contact_telephone'],
                ),
                Divider(
                  height: 50,
                ),
                DropdownInput<AdvertType>(
                  label: "Job Type",
                  items: [
                    DropdownOption<AdvertType>(
                        AdvertType.day_to_day, "Day to Day"),
                    DropdownOption<AdvertType>(
                        AdvertType.long_term, "Long Term")
                  ],
                  onChanged: formState.isSubmitting
                      ? null
                      : (value) => context
                          .read<CreateAdvertBloc>()
                          .add(CreateAdvertTypeChanged(value)),
                  value: formState.type,
                  errorText: formState.errors['type'],
                ),
                if (formState.type == AdvertType.day_to_day)
                  TextFieldInput(
                    label: "Apply within period (minutes)",
                    controller: _dayToDayActiveMinutesController,
                    enabled: !formState.isSubmitting,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    errorText: formState.errors['day_to_day_active_minutes'],
                  ),
                if (formState.type == AdvertType.long_term)
                  Row(
                    children: [
                      Expanded(
                        child: DateInput(
                          label: "Apply By Date",
                          enabled: !formState.isSubmitting,
                          controller: _applyByDateController,
                          initialDate: formState.applyByDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                          onChanged: (date) {
                            context
                                .read<CreateAdvertBloc>()
                                .add(CreateAdvertApplyByDateChanged(date));
                          },
                          errorText: formState.errors['apply_by'],
                        ),
                      ),
                      HSpacer(20),
                      Expanded(
                        child: TimeInput(
                          label: "Apply By Time",
                          enabled: !formState.isSubmitting,
                          controller: _applyByTimeController,
                          initialTime: formState.applyByTime,
                          onChanged: (time) {
                            context
                                .read<CreateAdvertBloc>()
                                .add(CreateAdvertApplyByTimeChanged(time));
                          },
                          errorText:
                              formState.errors['apply_by'] != null ? "" : null,
                        ),
                      ),
                    ],
                  ),
                Divider(
                  height: 50,
                ),
                LayoutBuilder(
                    builder: (context, constraints) => Row(
                          children: [
                            SizedBox(
                              width: (constraints.maxWidth / 2) - 10,
                              child: DropdownInput<PayRateType>(
                                label: "Pay Rate Type",
                                items: [
                                  DropdownOption<PayRateType>(
                                      PayRateType.daily, "Daily"),
                                  DropdownOption<PayRateType>(
                                      PayRateType.hourly, "Hourly")
                                ],
                                onChanged: formState.isSubmitting
                                    ? null
                                    : (value) => context
                                        .read<CreateAdvertBloc>()
                                        .add(CreateAdvertPayRateTypeChanged(
                                            value)),
                                value: formState.payRateType,
                                errorText: formState
                                    .errors['advertiser_pay_rate_type'],
                              ),
                            ),
                            HSpacer(20),
                            Expanded(
                              child: TextFieldInput(
                                label: "Pay Rate",
                                controller: _payRateController,
                                enabled: !formState.isSubmitting,
                                keyboardType: TextInputType.number,
                                textCapitalization: TextCapitalization.none,
                                textInputAction: TextInputAction.next,
                                leading: "£",
                                errorText:
                                    formState.errors['advertiser_pay_rate'],
                              ),
                            )
                          ],
                        )),
                Divider(
                  height: 50,
                ),
                InputLabel(label: 'Documents'),
                VSpacer(20),
                if (formState.documents.isEmpty) ...[
                  Text("No documents added"),
                  VSpacer(20),
                ] else ...[
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: formState.documents.length,
                    separatorBuilder: (context, index) => VSpacer(20),
                    itemBuilder: (context, index) {
                      final document = formState.documents[index];
                      return AdvertDocumentTile(
                          key: ValueKey(document.upload.url),
                          title: document.title,
                          url: document.upload.url,
                          enabled: !formState.isSubmitting,
                          onDeletePressed: () =>
                              context.read<CreateAdvertBloc>().add(
                                    CreateAdvertDocumentRemoved(index),
                                  ));
                    },
                  ),
                  VSpacer(20),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 14)),
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: formState.isSubmitting
                            ? null
                            : () async {
                                final document = await context
                                    .pushNamed<CreateAdvertDocument>(
                                        CreateDocumentPage.name);
                                if (document != null && context.mounted) {
                                  context
                                      .read<CreateAdvertBloc>()
                                      .add(CreateAdvertDocumentAdded(document));
                                }
                              },
                        label: Text("Add Document")),
                  ],
                ),
                Divider(
                  height: 50,
                ),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: formState.canSubmit
                                ? () => context
                                    .read<CreateAdvertBloc>()
                                    .add(CreateAdvertSubmitted())
                                : null,
                            child: Text(formState.isSubmitting
                                ? "Creating Job..."
                                : "Create Job"))),
                  ],
                )
              ],
            ));
      },
    );
  }
}
