part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();

  List<Object> get props => [];
}

class InitHomeEvent extends HomeEvent {
  const InitHomeEvent();
  @override
  List<Object> get props => [];
}

class FiltersRestaurantEvent extends HomeEvent {
  const FiltersRestaurantEvent({required this.type});
  final String type;
  @override
  List<Object> get props => [type];
}

class DialogsDisplayedEvent extends HomeEvent {}
