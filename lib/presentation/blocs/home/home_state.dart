part of 'home_bloc.dart';

@immutable
sealed class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeEmpty extends HomeState {}

// ignore: must_be_immutable
final class HomeLoadedState extends HomeState {
  HomeLoadedState({required this.restaurants, r});

  List<RestaurantEntity> restaurants;

  @override
  List<Object> get props => [restaurants];
}

// ignore: must_be_immutable
final class HomeExceptionState extends HomeState {
  HomeExceptionState(this.previousState);

  final HomeLoadedState previousState;

  @override
  List<Object> get props => [];
}

final class loadingState extends HomeState {
  loadingState(this.previousState);

  HomeLoadedState previousState;

  @override
  List<Object> get props => [];
}
