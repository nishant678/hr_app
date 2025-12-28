part of 'navigation_bloc.dart';

class NavigationStates extends Equatable {
  const NavigationStates({
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  NavigationStates copyWith({
    int? selectedIndex,
  }) {
    return NavigationStates(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object> get props => [selectedIndex];
}

