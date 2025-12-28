part of 'home_bloc.dart';

sealed class HomeEvents extends Equatable {
  const HomeEvents();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvents {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvents {
  const RefreshHomeData();
}

