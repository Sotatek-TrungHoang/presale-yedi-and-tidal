import 'package:flutter/material.dart';
import 'package:yedi_app/ui/inputs/input_layout.dart';

class DropdownOption<T> {
  final T value;
  final String label;

  DropdownOption(this.value, this.label);
}

class DropdownInput<T> extends StatelessWidget {
  const DropdownInput(
      {required this.items,
      required this.label,
      this.marginBottom = 20,
      this.value,
      this.onChanged,
      this.errorText,
      super.key});

  final T? value;
  final String label;
  final String? errorText;
  final void Function(T?)? onChanged;
  final List<DropdownOption<T>> items;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return InputLayout(
      label: label,
      input: LayoutBuilder(builder: (context, constraints) {
        return DropdownButtonFormField<T?>(
          value: value,
          onChanged: onChanged,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
              fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily),
          items: items
              .map((item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: SizedBox(
                    width: constraints.maxWidth - 75,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )))
              .toList(),
          elevation: 0,
        );
      }),
      errorText: errorText,
      marginBottom: marginBottom,
    );
  }
}
