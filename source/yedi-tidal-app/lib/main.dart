import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as flutter_libphonenumber;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yedi_app/modules/api/api.dart';
import 'package:yedi_app/modules/authentication/models/auth_user_model.dart';
import 'package:yedi_app/modules/authentication/services/authentication_service.dart';
import 'package:yedi_app/util/env.dart';
import 'package:yedi_app/util/firebase.dart';

import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:yedi_app/firebase_options.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  Env.validate();
  print(Env.print());

  await flutter_libphonenumber.init();
  await _initFirebase();
  await _initGetIt();

  final authenticationService = AuthenticationService();
  AuthUserModel? user;
  try {
    user = await authenticationService.getCurrentUser();
  } catch (e) {
    //
  }

  runApp(App(
    authenticationService: authenticationService,
    initialUser: user,
  ));
}

_initGetIt() async {
  getIt.registerSingleton<ApiService>(ApiService());
  getIt.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());
}

_initFirebase() async {
  await Firebase.initializeApp(
      name: appFlavor, options: DefaultFirebaseOptions.currentPlatform);

  if (!kDebugMode) {
    // FlutterError.onError = (errorDetails) {
    //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    // };

    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    //   return true;
    // };
  }

  bool apnsToken = true;
  if (Platform.isIOS) {
    apnsToken = (await FirebaseMessaging.instance.getAPNSToken()) != null;
  }

  if (apnsToken) {
    await FirebaseMessaging.instance.requestPermission(provisional: true);
    final fcmToken = await FirebaseMessaging.instance.getToken();
    getIt.registerSingleton<FirebaseToken>(FirebaseToken(token: fcmToken));
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      getIt.registerSingleton<FirebaseToken>(FirebaseToken(token: fcmToken));
    }).onError((err) {
      // Error getting token.
    });
  }
}
