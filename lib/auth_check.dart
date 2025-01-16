import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../routing/app_router.dart';
import '../routing/routes.dart';
import '../utils/user_data_util.dart';

class AuthCheck extends StatelessWidget {
  final AppRouter router;

  const AuthCheck({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UserDataUtil.checkFirstSeen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool isFirstTime = snapshot.data ?? true;

        if (isFirstTime) {
          return Navigator(
            onGenerateRoute: router.generateRoute,
            initialRoute: Routes.landingPage,
          );
        } else {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = snapshot.data;

              if (user == null) {
                return Navigator(
                  onGenerateRoute: router.generateRoute,
                  initialRoute: Routes.loginScreen,
                );
              } else if (!user.emailVerified) {
                return Navigator(
                  onGenerateRoute: router.generateRoute,
                  initialRoute: Routes.loginScreen,
                );
              } else {
                return FutureBuilder<Map<String, bool>>(
                  future: _checkParentAndChildDataComplete(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final dataStatus = snapshot.data ?? {};
                    final bool isParentDataComplete =
                        dataStatus['parentDataComplete'] ?? false;
                    final bool isChildDataComplete =
                        dataStatus['childDataComplete'] ?? false;

                    // Ensure initialRoute is always set
                    String initialRoute = Routes.homeScreen; 

                    if (!isParentDataComplete) {
                      initialRoute = Routes.parentForm;
                    } else if (!isChildDataComplete) {
                      initialRoute = Routes.childForm;
                    }

            

                    return Navigator(
                      onGenerateRoute: router.generateRoute,
                      initialRoute: initialRoute,
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  Future<Map<String, bool>> _checkParentAndChildDataComplete(String uid) async {
    bool isParentDataComplete = await UserDataUtil.checkParentDataComplete(uid);
    bool isChildDataComplete = await UserDataUtil.checkUserDataComplete(uid);

    return {
      'parentDataComplete': isParentDataComplete,
      'childDataComplete': isChildDataComplete,
    };
  }
}
