import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = "", this.maxLength,
    this.maxLine,
    this.keyboardType,
    this.readOnly = false,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final int? maxLength;
  final int? maxLine;
  final TextInputType? keyboardType;
  final bool readOnly;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      maxLength:maxLength,
      maxLines: maxLine,
      keyboardType: keyboardType,
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        label: Text(labelText),
        border: OutlineInputBorder(),
      ),
    );
  }
}


class CustomTextFieldPassword extends StatefulWidget {
  const CustomTextFieldPassword({
    super.key,
    required this.controller,
    this.labelText = "",
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  State<CustomTextFieldPassword> createState() => _CustomTextFieldPasswordState();
}

class _CustomTextFieldPasswordState extends State<CustomTextFieldPassword> {
  bool isObscure = true;
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      decoration: InputDecoration(
        label: Text(widget.labelText),
        border: OutlineInputBorder(),
        suffixIcon: IconButton(onPressed: (){
          setState(() {
            isObscure = !isObscure;
            isObscureText = !isObscureText;
          });
        },
            icon:Icon(isObscure? Icons.visibility_off: Icons.visibility)
      ),
    ),
      keyboardType: widget.keyboardType,
      obscureText: isObscureText,
    );
  }
}

