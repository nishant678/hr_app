import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_events.dart';
part 'navigation_states.dart';

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc() : super(const NavigationStates()) {
    on<ChangeTabIndex>(_onChangeTabIndex);
  }

  void _onChangeTabIndex(
    ChangeTabIndex event,
    Emitter<NavigationStates> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}

