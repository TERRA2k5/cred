import 'package:credd/bloc/SDUIEvent.dart';
import 'package:credd/bloc/SDUIState.dart';
import 'package:credd/service/ApiService.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SDUIBloc extends Bloc<SDUIEvent, SDUIState> {
  final MockApiService apiService;

  SDUIBloc(this.apiService) : super(const SDUILoading()) {
    on<FetchSDUIData>((event, emit) async {
      emit(const SDUILoading());
      try {
        final items = await apiService.fetchScreenComponents();
        emit(SDUILoaded(items));
      } catch (e) {
        emit(SDUIError(e.toString()));
      }
    });
  }
}
