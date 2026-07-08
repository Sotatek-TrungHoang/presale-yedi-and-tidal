import 'package:flutter/material.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class YesNoInput extends StatelessWidget {
  const YesNoInput({
    required this.text,
    required this.value,
    this.onChanged,
    this.errorText,
    super.key,
  });

  final String text;
  final String? errorText;
  final bool value;
  final Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: appColours.canvasBackground,
        foregroundColor: Colors.black,
        disabledBackgroundColor: Theme.of(context)
            .elevatedButtonTheme
            .style
            ?.backgroundColor!
            .resolve({WidgetState.disabled}),
        disabledForegroundColor: Theme.of(context)
            .elevatedButtonTheme
            .style
            ?.foregroundColor!
            .resolve({WidgetState.disabled}),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily,
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeBorderRadius),
        ),
      ),
      onPressed: onChanged == null
          ? null
          : () {
              onChanged!(!value);
            },
      child: Row(
        children: [
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              color: value ? appColours.success : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? appColours.success : Colors.black,
                width: 1,
              ),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          HSpacer(18),
          Expanded(child: Text(text))
        ],
      ),
    );
  }
}
