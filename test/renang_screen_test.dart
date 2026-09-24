import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jasmani_flutter/data/renang_logic.dart';
import 'package:jasmani_flutter/screens/renang_screen.dart';
import 'package:jasmani_flutter/theme/app_theme.dart';

void main() {
  testWidgets('Renang: isi umur & waktu pria menampilkan nilai akhir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const RenangScreen(config: renangDasarConfig),
      ),
    );

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4)); // pria: umur, waktu; wanita: umur, waktu

    await tester.enterText(fields.at(0), '27');
    await tester.enterText(fields.at(1), '1.00');
    await tester.pump();

    // Kategori 3, nilai dasar 73, hasil 79, nilai akhir 79.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('73'), findsOneWidget);
    expect(find.text('79'), findsNWidgets(2));

    // Waktu yang tidak ada di tabel memunculkan peringatan.
    await tester.enterText(fields.at(1), '9.99');
    await tester.pump();
    expect(find.text('Waktu tidak ada di tabel nilai'), findsOneWidget);
  });

  testWidgets('Renmil menampilkan judul yang benar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const RenangScreen(config: renmilConfig),
      ),
    );
    expect(find.text('RENANG MILITER DASAR'), findsOneWidget);
    expect(find.text('RENANG MILITER DASAR PRIA'), findsOneWidget);
    expect(find.text('RENANG MILITER DASAR WANITA'), findsOneWidget);
  });
}
