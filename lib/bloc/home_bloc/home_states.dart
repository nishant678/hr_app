part of 'home_bloc.dart';

class HomeStates extends Equatable {
  const HomeStates({
    this.isLoading = false,
    this.totalEmployees = 0,
    this.totalPresent = 0,
    this.totalLate = 0,
    this.totalLeave = 0,
    this.error = '',
  });

  final bool isLoading;
  final int totalEmployees;
  final int totalPresent;
  final int totalLate;
  final int totalLeave;
  final String error;

  HomeStates copyWith({
    bool? isLoading,
    int? totalEmployees,
    int? totalPresent,
    int? totalLate,
    int? totalLeave,
    String? error,
  }) {
    return HomeStates(
      isLoading: isLoading ?? this.isLoading,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      totalPresent: totalPresent ?? this.totalPresent,
      totalLate: totalLate ?? this.totalLate,
      totalLeave: totalLeave ?? this.totalLeave,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
        isLoading,
        totalEmployees,
        totalPresent,
        totalLate,
        totalLeave,
        error,
      ];
}

