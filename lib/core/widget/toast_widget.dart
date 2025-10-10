import 'package:NutriCam/core/values/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class ToastWidget {
  toastSuccess(String message) {
    if (!Platform.isWindows) {
      FocusManager.instance.primaryFocus?.unfocus();
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: colorGreen1,
          textColor: colorWhite1,
          fontSize: 16.0);
    }
  }

  toastError(String message) {
    if (!Platform.isWindows) {
      FocusManager.instance.primaryFocus?.unfocus();
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: colorRed1,
          textColor: colorWhite1,
          fontSize: 16.0);
    }
  }

}
