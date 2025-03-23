/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'dart:developer' as dev;
import 'package:dev_colorized_log/dev_logger.dart';

import 'package:flutter/foundation.dart';

class DevColorizedLog {
  static void logCustom(
    String msg, {
    bool enable = true,
    int colorInt = 0,
    bool? isLog,
    bool? isMultConsole,
    bool? isDebugPrint,
    String? fileInfo,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = 'logNor',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    bool? execFinalFunc,
  }) {
    _custom(
      msg,
      enable: enable,
      colorInt: colorInt,
      isLog: isLog,
      isMultConsole: isMultConsole,
      isDebugPrint: isDebugPrint,
      fileInfo: fileInfo,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
      execFinalFunc: execFinalFunc,
    );
  }

  static void _custom(
    String msg, {
    bool enable = true,
    int colorInt = 0,
    bool? isLog,
    bool? isMultConsole,
    bool? isDebugPrint,
    String? fileInfo,
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = 'logNor',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
    bool? execFinalFunc,
  }) {
    bool isExe = execFinalFunc != null && execFinalFunc;
    final finalName = isExe ? '$name&Exe' : name;
    DateTime now = DateTime.now();
    String formattedNow = Dev.isLogShowDateTime ? '$now' : '';

    void logging() {
      if (isExe && !Dev.isExeWithShowLog) {
        return;
      }
      if ((isMultConsole != null && isMultConsole == true) || Dev.isMultConsoleLog) {
        if (isDebugPrint == null || isDebugPrint) {
          debugPrint('\x1B[${colorInt}m[$finalName]$formattedNow${fileInfo ?? ''}$msg\x1B[0m');
        } else {
          // ignore: avoid_print
          print('\x1B[${colorInt}m[$finalName]$formattedNow${fileInfo ?? ''}$msg\x1B[0m');
        }
      } else {
        dev.log(
          '\x1B[${colorInt}m$formattedNow${fileInfo ?? ''}$msg\x1B[0m',
          time: time,
          sequenceNumber: sequenceNumber,
          level: level,
          name: '\x1B[${colorInt}m$finalName\x1B[0m',
          zone: zone,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (isLog != null && isLog) {
      logging();
    } else if (enable) {
      if (isLog == null || isLog) {
        logging();
      }
    }

    if (isExe) {
      Dev.customFinalFunc?.call(
          '[$finalName]${Dev.isExeWithDateTime ? '$now' : ''}${fileInfo ?? ''}$msg');
    }
  }
}
