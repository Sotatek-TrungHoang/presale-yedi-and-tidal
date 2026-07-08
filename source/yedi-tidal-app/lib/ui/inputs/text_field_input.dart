import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yedi_app/ui/inputs/input_layout.dart';

class TextFieldInput extends StatefulWidget {
  const TextFieldInput(
      {required this.label,
      this.initialValue,
      this.onChanged,
      this.controller,
      this.errorText,
      this.keyboardType,
      this.textInputAction,
      this.validator,
      this.inputFormatters,
      this.textCapitalization = TextCapitalization.none,
      this.marginBottom = 20,
      this.enabled = true,
      this.obscureText = false,
      this.toggleObscureText = false,
      this.leading,
      this.maxLines = 1,
      this.maxLength,
      super.key});

  final TextEditingController? controller;
  final String label;
  final String? errorText;
  final double marginBottom;

  final String? initialValue;
  final void Function(String)? onChanged;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool toggleObscureText;
  final String? leading;
  final int? maxLines;
  final int? maxLength;

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  late bool _textObscured;

  @override
  void initState() {
    super.initState();
    _textObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry? inputPadding;

    if (widget.toggleObscureText && widget.leading != null) {
      inputPadding = EdgeInsets.only(left: 36, top: 20, bottom: 20, right: 72);
    } else if (widget.toggleObscureText) {
      inputPadding = EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 72);
    } else if (widget.leading != null) {
      inputPadding = EdgeInsets.only(left: 36, top: 20, bottom: 20, right: 20);
    }

    return InputLayout(
      label: widget.label,
      input: Stack(
        children: [
          TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            initialValue: widget.initialValue,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            obscureText: _textObscured,
            onChanged: widget.onChanged,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            maxLines: widget.maxLines,
            decoration: InputDecoration(contentPadding: inputPadding),
            maxLength: widget.maxLength,
          ),
          if (widget.leading != null)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  widget.leading!,
                ),
              ),
            ),
          if (widget.toggleObscureText)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AspectRatio(
                aspectRatio: 1,
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    _textObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: !widget.enabled
                      ? null
                      : () {
                          setState(() {
                            _textObscured = !_textObscured;
                          });
                        },
                ),
              ),
            ),
        ],
      ),
      errorText: widget.errorText,
      marginBottom: widget.marginBottom,
    );
  }
}
