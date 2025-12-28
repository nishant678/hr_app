part of 'navigation_bloc.dart';

sealed class NavigationEvents extends Equatable {
  const NavigationEvents();

  @override
  List<Object> get props => [];
}

class ChangeTabIndex extends NavigationEvents {
  final int index;
  const ChangeTabIndex({required this.index});

  @override
  List<Object> get props => [index];
}

