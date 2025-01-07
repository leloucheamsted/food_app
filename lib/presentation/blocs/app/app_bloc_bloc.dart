import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_bloc_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitialState()) {
    on<AppEvent>((event, emit) {});
  }
}
