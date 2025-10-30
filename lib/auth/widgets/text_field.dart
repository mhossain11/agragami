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
    this.enabled,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String labelText;
  final int? maxLength;
  final int? maxLine;
  final TextInputType? keyboardType;
  final bool readOnly;
  final String? Function(String?)? validator;
  final bool? enabled;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      maxLength:maxLength,
      maxLines: maxLine,
      keyboardType: keyboardType,
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: labelText,
            style: TextStyle(color: Colors.black,fontSize: 16),
            children: isRequired ? [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ]: []
),
      ),
        border: OutlineInputBorder(),
      )
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
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;

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
        label: RichText(
          text: TextSpan(
              text: widget.labelText,
              style: TextStyle(color: Colors.black,fontSize: 16),
              children: widget.isRequired ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]: []
          ),
        ),
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

