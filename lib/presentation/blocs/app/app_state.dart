// ignore_for_file: prefer_const_constructors_in_immutables, must_be_immutable

part of 'app_bloc_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

final class AppInitialState extends AppState {}

final class AppLanguageSetState extends AppState {
  AppLanguageSetState(this.languageCode, this.countryCode);
  final String languageCode;
  final String countryCode;

  @override
  List<Object> get props => [languageCode];
}

final class AppBarSetState extends AppState {
  AppBarSetState(this.showAppBar);
  bool showAppBar;

  @override
  List<Object> get props => [showAppBar = false];
}
