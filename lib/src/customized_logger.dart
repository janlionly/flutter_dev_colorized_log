/*
 * Author: janlionly (janlionly@gmail.com)
 * Date:   2023-09-21
 */
import 'dart:async';
import 'dart:developer' as dev;
import 'package:dev_colorized_log/dev_logger.dart';

import 'package:flutter/foundation.dart';

class DevColorizedLog {
  static void logCustom(String msg, {
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

  static void _custom(String msg, {
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
    void logging() {
      if (isMultConsole != null && isMultConsole == true) {
        if (isDebugPrint == null || isDebugPrint) {
          debugPrint('${fileInfo??''}$msg');
          if (execFinalFunc != null && execFinalFunc) {
            Dev.customFinalFunc?.call('[debugPrint]${fileInfo??''}$msg');
          }
        } else {
          // ignore: avoid_print
          print('${fileInfo??''}$msg');
          if (execFinalFunc != null && execFinalFunc) {
            Dev.customFinalFunc?.call('[print]${fileInfo??''}$msg');
          }
        }
      } else {
        dev.log('\x1B[${colorInt}m${fileInfo??''}$msg\x1B[0m', 
          time: time,
          sequenceNumber: sequenceNumber,
          level: level,
          name: name,
          zone: zone,
          error: error,
          stackTrace: stackTrace,
        );
        if (execFinalFunc != null && execFinalFunc) {
          Dev.customFinalFunc?.call('[$name]${fileInfo??''}$msg');
        }
      }
    }

    if (isLog != null && isLog) {
      logging();
    }
    else if (enable) {
      if (isLog == null || isLog) {
        logging();
      }
    }
  }
}