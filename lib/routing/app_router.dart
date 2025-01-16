import 'package:flutter/material.dart';
import 'package:simoga/model/child_nutrition.dart';
import 'package:simoga/screens/profile/parent_profile_page.dart'
    as parentProfile;
import 'package:simoga/screens/profile/child_profile_page.dart' as childProfile;
import 'package:simoga/screens/parent/ui/parent_form.dart';
import '../model/program_intervensi.dart';
import '../screens/forget/ui/forget_screen.dart';
import '../screens/home/ui/home_screen.dart';
import '../screens/login/ui/login_screen.dart';
import '../screens/signup/ui/sign_up_sceen.dart';
import '../screens/landing_page/landing_page.dart';
import '../screens/child/ui/child_form_page.dart';
import '../screens/child/ui/child_list.dart';
import '../screens/child/ui/child_detail.dart';
import '../screens/child/ui/child_tab.dart';
import '../screens/child/ui/child_nutrition.dart';
import '../screens/meal/ui/widget/meal_detail_screen.dart';
import '../screens/konten_edukasi/ui/education_content_list.dart';
import 'routes.dart';
import '../screens/program_intervensi/ui/program_detail_page.dart';
import '../screens/program_intervensi/ui/program_intervensi_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>?;
    final currentUser = FirebaseAuth.instance.currentUser;

    switch (settings.name) {
      case Routes.forgetScreen:
        return MaterialPageRoute(
          builder: (_) => const ForgetScreen(),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case Routes.parentForm:
        final userId = arguments?['userId'] as String? ?? currentUser?.uid;
        if (userId != null) {
          return MaterialPageRoute(
            builder: (_) => ParentForm(userId: userId),
          );
        }

        return _errorRoute();
      case Routes.programIntervensiList:
        return MaterialPageRoute(
            builder: (_) => const ProgramIntervensiListPage());
      case Routes.programDetail:
        if (arguments != null && arguments.containsKey('program')) {
          return MaterialPageRoute(
            builder: (_) => ProgramDetailPage(
              program: arguments['program'] as ProgramIntervensi,
            ),
          );
        }
        return _errorRoute();

      case Routes.educationContentList:
        return MaterialPageRoute(
          builder: (_) => EducationContentListScreen(),
        );
      // Route lainnya
      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case Routes.landingPage:
        return MaterialPageRoute(
          builder: (_) => const LandingPage(),
        );
      case Routes.childForm:
        // Safely handle arguments
        return MaterialPageRoute(
          builder: (_) => ChildFormPage(childData: arguments),
        );
      case Routes.childList:
        return MaterialPageRoute(
          builder: (_) => const ChildListPage(),
        );
      case Routes.childDetail:
        return MaterialPageRoute(
          builder: (_) => ChildDetailPage(childData: arguments),
        );
      case Routes.childTabs:
        return MaterialPageRoute(
          builder: (_) => ChildTabsScreen(
            onChildSelected: (index) {},
          ),
        );
      case Routes.childNutritionScreen:
        if (arguments != null &&
            arguments.containsKey('nutrition') &&
            arguments.containsKey('childId') &&
            arguments['nutrition'] is ChildNutrition &&
            arguments['childId'] is String) {
          return MaterialPageRoute(
            builder: (_) => ChildNutritionScreen(
              nutrition: arguments['nutrition'] as ChildNutrition,
              onNutritionUpdated:
                  arguments['onNutritionUpdated'] as Function(ChildNutrition),
              childId: arguments['childId'] as String,
            ),
          );
        }
        return _errorRoute();

      case Routes.mealDetailScreen:
        if (arguments != null &&
            arguments.containsKey('mealDescription') &&
            arguments.containsKey('calories') &&
            arguments.containsKey('childId')) {
          return MaterialPageRoute(
            builder: (_) => MealDetailScreen(
              mealDescription: arguments['mealDescription'],
              calories: arguments['calories'],
              childId: arguments['childId'],
            ),
          );
        }
        return _errorRoute();

      case Routes.parentProfile:
        return MaterialPageRoute(
          builder: (_) => const parentProfile.ParentProfilePage(),
        );

      case Routes.childProfile:
        return MaterialPageRoute(
          builder: (_) => const childProfile.ChildProfilePage(),
        );

      default:
        return _errorRoute();
    }
  }

  Route _errorRoute() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return MaterialPageRoute(
      builder: (_) => ParentForm(
        userId: currentUser?.uid ??
            'unknownUserId', // Fallback to a default or error-handling scenario
      ),
    );
  }
}
