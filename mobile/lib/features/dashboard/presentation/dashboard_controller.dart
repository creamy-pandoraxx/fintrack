import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
      DashboardController.new,
    );

class DashboardState {
  const DashboardState({
    required this.period,
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  final DashboardPeriod period;
  final DashboardSummary? summary;
  final bool isLoading;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardPeriod? period,
    DashboardSummary? summary,
    bool? isLoading,
    String? errorMessage,
    bool clearSummary = false,
    bool clearError = false,
  }) {
    return DashboardState(
      period: period ?? this.period,
      summary: clearSummary ? null : summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() => DashboardState(period: DashboardPeriod.current());

  Future<void> loadSummary({DashboardPeriod? period}) async {
    final targetPeriod = period ?? state.period;
    final periodChanged =
        targetPeriod.month != state.period.month ||
        targetPeriod.year != state.period.year;

    state = state.copyWith(
      period: targetPeriod,
      isLoading: true,
      clearSummary: periodChanged,
      clearError: true,
    );

    try {
      final summary = await ref
          .read(dashboardRepositoryProvider)
          .getSummary(targetPeriod);

      state = state.copyWith(
        summary: summary,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFrom(error),
      );
    }
  }

  Future<void> showPreviousMonth() {
    return loadSummary(period: state.period.previous());
  }

  Future<void> showNextMonth() {
    return loadSummary(period: state.period.next());
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _messageFrom(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
