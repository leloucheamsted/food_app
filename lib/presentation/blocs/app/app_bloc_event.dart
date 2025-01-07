// ignore_for_file: must_be_immutable

part of 'app_bloc_bloc.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class InitAppEvent extends AppEvent {}

class SetAppThemeEvent extends AppEvent {
  // ignore: prefer_const_constructors_in_immutables
  SetAppThemeEvent({required this.theme});
  final String theme;

  @override
  List<Object> get props => [theme];
}

class SetAppLanguageEvent extends AppEvent {
  // ignore: prefer_const_constructors_in_immutables
  SetAppLanguageEvent(this.languageCode, this.countryCode);
  final String languageCode;
  final String countryCode;

  @override
  List<Object> get props => [languageCode, countryCode];
}

class SendAppConfigEvent extends AppEvent {
  // ignore: prefer_const_constructors_in_immutables
  SendAppConfigEvent(this.languageCode, this.countryCode, this.deviceId);
  final String languageCode;
  final String countryCode;
  final String deviceId;

  @override
  List<Object> get props => [languageCode, countryCode, deviceId];
}

class SetShowAppBarEvent extends AppEvent {
  // ignore: prefer_const_constructors_in_immutables
  SetShowAppBarEvent({required this.showAppBar});
  bool showAppBar;

  @override
  List<Object> get props => [showAppBar = false];
}
