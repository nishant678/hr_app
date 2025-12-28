import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_events.dart';
part 'home_states.dart';

class HomeBloc extends Bloc<HomeEvents, HomeStates> {
  HomeBloc() : super(const HomeStates()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeStates> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    // Simulate API call or data loading
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would fetch data from a repository
    // For now, using mock data
    emit(
      state.copyWith(
        isLoading: false,
        totalEmployees: 65,
        totalPresent: 59,
        totalLate: 12,
        totalLeave: 6,
      ),
    );
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeStates> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    // Simulate API call or data loading
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would fetch data from a repository
    emit(
      state.copyWith(
        isLoading: false,
        totalEmployees: 65,
        totalPresent: 59,
        totalLate: 12,
        totalLeave: 6,
      ),
    );
  }
}

