import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/activity_feed_item.dart';
import 'activity_feed_dto.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return FirestoreActivityRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final activityFeedProvider = StreamProvider.autoDispose<List<ActivityFeedItem>>(
  (ref) {
    return ref
        .watch(activityRepositoryProvider)
        .watchLatestActivities(limit: 20);
  },
);

final activityFeedPreviewProvider =
    StreamProvider.autoDispose<List<ActivityFeedItem>>((ref) {
      return ref
          .watch(activityRepositoryProvider)
          .watchLatestActivities(limit: 3);
    });

abstract class ActivityRepository {
  Stream<List<ActivityFeedItem>> watchLatestActivities({required int limit});
}

class FirestoreActivityRepository implements ActivityRepository {
  const FirestoreActivityRepository({
    required this.firebaseAuth,
    required this.firestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore? firestore;

  @override
  Stream<List<ActivityFeedItem>> watchLatestActivities({
    required int limit,
  }) async* {
    final user = firebaseAuth.currentUser;
    final db = firestore;

    if (user == null || db == null) {
      yield const [];
      return;
    }

    try {
      final snapshots = db
          .collection('users')
          .doc(user.uid)
          .collection('activity_feed')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots();

      await for (final snapshot in snapshots) {
        yield snapshot.docs
            .map(ActivityFeedDto.fromDocument)
            .map((dto) => dto.toDomain())
            .toList();
      }
    } on FirebaseException catch (error) {
      throw ActivityFeedException(_firestoreMessage(error));
    } catch (_) {
      throw const ActivityFeedException(
        'Activity feed is unavailable right now.',
      );
    }
  }

  String _firestoreMessage(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Firestore rules are blocking activity feed reads. Deploy mobile/firestore.rules and sign in again.',
      'failed-precondition' =>
        'Activity feed needs a Firestore index before it can be loaded.',
      'unavailable' => 'Activity feed is temporarily unavailable.',
      _ => 'Activity feed is unavailable right now.',
    };
  }
}

class ActivityFeedException implements Exception {
  const ActivityFeedException(this.message);

  final String message;

  @override
  String toString() => message;
}
