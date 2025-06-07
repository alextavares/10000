import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// InputFormatter personalizado que permite caracteres especiais do português
class PortugueseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    // Permite todos os caracteres, incluindo acentos e cedilha
    return newValue;
  }
}

/// Widget de TextField otimizado para português brasileiro
class PortugueseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? style;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final bool enableInteractiveSelection;

  const PortugueseTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.style,
    this.decoration,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.sentences,
    this.enableInteractiveSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: style,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: textCapitalization,
      enableInteractiveSelection: enableInteractiveSelection,
      // Configurações importantes para caracteres especiais
      enableSuggestions: true,
      autocorrect: true,
      // Permite todos os caracteres, incluindo especiais
      inputFormatters: [
        // Não limita caracteres - permite ç, ã, õ, etc.
        PortugueseTextInputFormatter(),
      ],
      decoration: decoration ?? InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Extensão para facilitar a criação de TextFormFields com suporte a português
extension PortugueseTextFieldExtension on TextFormField {
  static TextFormField portuguese({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    TextStyle? style,
    InputDecoration? decoration,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLines = 1,
    int? minLines,
    bool autofocus = false,
    FocusNode? focusNode,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    bool enableInteractiveSelection = true,
  }) {
    return TextFormField(
      controller: controller,
      style: style,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      textCapitalization: textCapitalization,
      enableInteractiveSelection: enableInteractiveSelection,
      enableSuggestions: true,
      autocorrect: true,
      inputFormatters: [
        PortugueseTextInputFormatter(),
      ],
      decoration: decoration ?? InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
