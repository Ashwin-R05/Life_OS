import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:life_os/main.dart';
import 'package:life_os/features/onboarding/controller/onboarding_controller.dart';

void main() {
  testWidgets('Onboarding welcome screen smoke test', (WidgetTester tester) async {
    final controller = OnboardingController();
    
    await tester.pumpWidget(
      ChangeNotifierProvider<OnboardingController>.value(
        value: controller,
        child: const MyApp(initialRoute: '/onboarding'),
      ),
    );

    // Verify that our Welcome screen is shown.
    expect(find.text('LifeOS'), findsOneWidget);
    expect(find.text('Begin Configuration'), findsOneWidget);
  });
}
