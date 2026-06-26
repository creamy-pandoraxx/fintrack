import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/finance_tip.dart';
import 'finance_tip_dto.dart';

final financeTipsRepositoryProvider = Provider<FinanceTipsRepository>((ref) {
  return FirestoreFinanceTipsRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final activeFinanceTipsProvider = StreamProvider.autoDispose<List<FinanceTip>>((
  ref,
) {
  return ref.watch(financeTipsRepositoryProvider).watchActiveTips();
});

abstract class FinanceTipsRepository {
  Stream<List<FinanceTip>> watchActiveTips();
}

class FirestoreFinanceTipsRepository implements FinanceTipsRepository {
  const FirestoreFinanceTipsRepository({required this.firestore});

  final FirebaseFirestore? firestore;

  @override
  Stream<List<FinanceTip>> watchActiveTips() async* {
    final db = firestore;
    if (db == null) {
      yield const [];
      return;
    }

    try {
      final snapshots = db
          .collection('finance_tips')
          .where('isActive', isEqualTo: true)
          .limit(20)
          .snapshots();

      await for (final snapshot in snapshots) {
        final tips =
            snapshot.docs
                .map(FinanceTipDto.fromDocument)
                .where((dto) => dto.isActive)
                .map((dto) => dto.toDomain())
                .toList()
              ..sort(_newestFirst);

        yield tips;
      }
    } on FirebaseException {
      yield const [];
    } catch (_) {
      yield const [];
    }
  }

  int _newestFirst(FinanceTip a, FinanceTip b) {
    final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return right.compareTo(left);
  }
}
