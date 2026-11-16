import 'package:credd/bloc/SDUIEvent.dart';
import 'package:credd/bloc/SDUIState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';


@injectable
class SDUIBloc extends Bloc<SDUIEvent, SDUIState> {
  // final SDUIRepository repository;

  SDUIBloc(/* this.repository */) : super(SDUILoading()) {
    on<FetchSDUIData>((event, emit) async {
      emit(SDUILoading());
      try {
        // final items = await repository.getScreenComponents();
        final items = []; // Placeholder until repo is connected
        // emit(SDUILoaded(items));
      } catch (e) {
        emit(SDUIError(e.toString()));
      }
    });
  }
}