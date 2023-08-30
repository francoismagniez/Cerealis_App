import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cerealis_app/main.dart';

void main() {
  // 1. Teste que l'application s'exécute et affiche le widget "AugmentedPage"
  testWidgets('Lancement de l\'application et affichage d\'AugmentedPage', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(AugmentedPage), findsOneWidget);
  });

  // 2. Vérifie si les boutons de capture d'image et de partage de capture d'écran sont présents.
  testWidgets('Boutons de capture et de partage présents', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byIcon(Icons.camera_alt), findsOneWidget); // Bouton de capture
    expect(find.byIcon(Icons.share), findsOneWidget);      // Bouton de partage
  });

  // 3. Teste si le formulaire s'affiche lorsqu'on appuie sur le bouton d'interaction.
  testWidgets('Affichage du formulaire après avoir appuyé sur le bouton d\'interaction', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Appuyez sur le bouton d'interaction
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Attendez que toutes les animations soient terminées

    // Vérifiez si les champs du formulaire sont présents
    expect(find.byIcon(Icons.account_circle), findsOneWidget);  // Champ de prénom
    expect(find.byIcon(Icons.email), findsOneWidget);           // Champ email
    expect(find.text("VALIDER"), findsOneWidget);               // Bouton de validation
  });


}