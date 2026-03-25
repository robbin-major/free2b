import 'package:flutter/material.dart';
import 'package:flutter_template/generated/l10n.dart';
import 'package:flutter_template/utils/language/language_spanish.dart';
import 'package:flutter_template/utils/language/language_us.dart';
import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'es_ES': sp,
        'en_US': en,
      };
}
