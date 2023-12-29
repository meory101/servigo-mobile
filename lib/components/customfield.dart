import 'package:flutter/material.dart';
import 'package:servigo/theme/app_size.dart';
import 'package:servigo/theme/colors.dart';

class customField extends StatefulWidget {
  String hint;
  TextInputType? ketype;
  Widget? iconbtn;
  bool? showpassword;
  Widget? suffix;
  bool? enabled;
  Key? fromkey;
  String? val;
  TextStyle? style;
  int? length;
  int? min;
  int? max;
  String? Function(String?)? validator;
  customField({
    required this.hint,
    this.iconbtn,
    this.showpassword,
    this.suffix,
    this.ketype,
    this.enabled,
    this.validator,
    this.fromkey,
    this.val,
    this.style,
  });

  @override
  State<customField> createState() => _customFieldState();
}

class _customFieldState extends State<customField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.val,
      style: widget.style,
      key: widget.fromkey,
      validator: widget.validator,
      enabled: widget.enabled,
      keyboardType: widget.ketype,
      cursorColor: maincolor.withOpacity(0.4),
      obscureText: widget.showpassword == null ? false : widget.showpassword!,
      decoration: InputDecoration(
        suffixIcon: widget.iconbtn,
        suffix: widget.suffix,
        hintText: widget.hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(border_rad_size),
          borderSide: BorderSide(
            color: maincolor.withOpacity(0.4).withOpacity(0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(border_rad_size),
          borderSide: BorderSide(color: maincolor.withOpacity(0.4)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(border_rad_size),
          borderSide: BorderSide(color: maincolor.withOpacity(0.4)),
        ),
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(border_rad_size),
          borderSide: BorderSide(color: errorcolor),
        ),
      ),
    );
  }
}
