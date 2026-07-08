import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yedi_app/l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yedi_app/pages/login/login_page.dart';
import 'package:yedi_app/pages/sign_up/sign_up_page.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class LandingContent extends StatefulWidget {
  const LandingContent({super.key});

  @override
  State<LandingContent> createState() => _LandingContentState();
}

class _LandingContentState extends State<LandingContent> {
  final bool _loggingIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: appColours.landingIconBg,
                    borderRadius: BorderRadius.circular(8)),
                child: SvgPicture.asset(
                  "assets/$appFlavor/logo.svg",
                  theme: SvgTheme(currentColor: Colors.white),
                ),
              ),
              const VSpacer(36),
              Text(
                AppLocalizations.of(context)!.appTagline,
                style: TextStyle(fontSize: 24),
              )
            ],
          )),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                  onPressed: _loggingIn
                      ? null
                      : () => context.pushNamed(SignUpPage.name),
                  child: Text("Sign Up")),
              const VSpacer(12),
              // Row(
              //   children: [
              //     Expanded(child: Divider()),
              //     HSpacer(20),
              //     const Text(
              //       "or",
              //       textAlign: TextAlign.center,
              //     ),
              //     HSpacer(20),
              //     Expanded(child: Divider()),
              //   ],
              // ),
              // const VSpacer(24),
              // ElevatedButton(
              //     onPressed: _loggingIn
              //         ? null
              //         : () => _signInWithApplePressed(context),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(Icons.apple),
              //         HSpacer(4),
              //         Text("Continue with Apple"),
              //       ],
              //     )),
              // const VSpacer(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: _loggingIn
                            ? null
                            : () => context.goNamed(LoginPage.name),
                        child: const Text("I already have an account")),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // _signInWithApplePressed(BuildContext context) async {
  //   setState(() {
  //     _loggingIn = true;
  //   });

  //   try {
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //       webAuthenticationOptions: WebAuthenticationOptions(
  //           clientId: 'com.ne6.yedi.service',
  //           redirectUri: Uri.parse(
  //               "https://api.yedi.anysix.dev/api/app/oauth/apple/callback")),
  //     );
  //     print(credential);
  //     final signInWithAppleEndpoint = Uri(
  //       scheme: 'https',
  //       host: 'api.yedi.anysix.dev',
  //       // host: 'api.yedi.anysix.dev',
  //       path: '/api/app/oauth/apple/sign-in',
  //       queryParameters: <String, String>{
  //         'code': credential.authorizationCode,
  //         if (credential.givenName != null) 'firstName': credential.givenName!,
  //         if (credential.familyName != null) 'lastName': credential.familyName!,
  //         'useBundleId': !kIsWeb && (Platform.isIOS || Platform.isMacOS)
  //             ? 'true'
  //             : 'false',
  //         if (credential.state != null) 'state': credential.state!,
  //       },
  //     );

  //     final session = await http.Client().post(
  //       signInWithAppleEndpoint,
  //     );

  //     final token = jsonDecode(session.body);
  //     final sharedPreferences = getIt.get<SharedPreferences>();
  //     await sharedPreferences.setString('bearerToken', token);
  //     if (context.mounted) {
  //       // final authService = context.read<AuthenticationService>();
  //       // authService.initialiseUser();
  //     }
  //   } catch (e) {
  //     print(e);
  //     setState(() {
  //       _loggingIn = false;
  //     });
  //   }
  // }
}
