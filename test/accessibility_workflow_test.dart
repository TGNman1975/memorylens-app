import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_lens/database/app_database.dart';
import 'package:memory_lens/main.dart';
import 'package:memory_lens/providers/memory_provider.dart';
import 'package:memory_lens/repositories/memory_repository.dart';
import 'package:provider/provider.dart';

void main() {
  for (final (scale, width) in [(1.0, 390.0), (1.6, 360.0), (3.1, 320.0)]) {
    testWidgets('capture, file, search and edit at ${scale}x and ${width}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 650);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      const folder = Folder(
        id: 1,
        name: 'Family and friends across Australia and New Zealand',
        nameKey: 'family',
      );
      final provider = _MemoryProvider(db)..folders = [folder];
      addTearDown(provider.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<MemoryProvider>.value(
          value: provider,
          child: const MemoryLensApp(),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> reveal(Finder matches) async {
        if (matches.evaluate().isEmpty) {
          final scrollable = find
              .descendant(
                of: find.byType(ListView),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Scrollable &&
                      widget.axisDirection == AxisDirection.down,
                ),
              )
              .first;
          final position = tester.state<ScrollableState>(scrollable).position;
          position.jumpTo(position.minScrollExtent);
          await tester.pumpAndSettle();
          while (matches.evaluate().isEmpty &&
              position.pixels < position.maxScrollExtent) {
            position.jumpTo(
              (position.pixels + 100).clamp(0, position.maxScrollExtent),
            );
            await tester.pumpAndSettle();
          }
        }
        expect(matches, findsWidgets);
        await tester.ensureVisible(matches.last);
        await tester.pumpAndSettle();
      }

      Future<void> tapText(String text) async {
        final matches = find.text(text);
        await reveal(matches);
        await tester.tap(matches.last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tapText('Create Your First Memory');
      await tapText('Quick Note');
      Finder field(String label) => find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == label,
      );
      const title =
          'Holiday photos and memories with the whole extended family';
      await tester.enterText(field('Title'), title);
      final notes = field('Notes');
      await reveal(notes);
      final longNote = List.filled(35, 'A long note.').join(' ');
      await tester.enterText(notes, longNote);
      await tapText('Folder (optional)');
      await tapText(folder.name);
      tester.view.viewInsets = const FakeViewPadding(bottom: 270);
      await tester.pumpAndSettle();
      await tapText('Save');
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(provider.memories.single.folderId, folder.id);
      expect(provider.memories.single.title, title);
      expect(provider.memories.single.note, longNote);

      await tester.enterText(find.byType(TextField), 'Holiday');
      await tester.pumpAndSettle();
      await tapText(title);
      await tapText('Set Reminder');
      if (scale > 1.5) await tapText('OK');
      await tapText('Cancel');
      await tapText('Edit Memory');
      await tapText('Folder (optional)');
      await tapText('Unfiled');
      await tapText('Save Changes');
      expect(provider.memories.single.folderId, isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byTooltip('Folders'), findsOneWidget);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tapText('Statistics');
      expect(find.text('Total Memories'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _MemoryProvider extends MemoryProvider {
  _MemoryProvider(AppDatabase db) : super(MemoryRepository(db));
  Memory? _memory;

  @override
  List<Memory> get memories => [?_memory];

  @override
  Future<void> loadMemories() async {}

  @override
  Future<void> addMemory({
    required String title,
    String? note,
    String? imagePath,
    bool favourite = false,
    DateTime? reminderAt,
    int? folderId,
  }) async {
    _memory = Memory(
      id: 1,
      title: title,
      note: note,
      favourite: favourite,
      createdAt: DateTime(2026),
      folderId: folderId,
    );
    notifyListeners();
  }

  @override
  Future<void> updateMemory({
    required Memory existing,
    required String title,
    String? note,
    bool favourite = false,
    DateTime? reminderAt,
    Value<int?> folderId = const Value.absent(),
  }) async {
    _memory = existing.copyWith(
      title: title,
      note: Value(note),
      folderId: folderId,
    );
    notifyListeners();
  }
}
