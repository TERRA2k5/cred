import 'package:credd/models/SDUI_model.dart';

abstract class SDUIState {}

class SDUILoading extends SDUIState {}

class SDUILoaded extends SDUIState {
  final List<SDUIModel> items;
  SDUILoaded(this.items);
}

class SDUIError extends SDUIState {
  final String message;
  SDUIError(this.message);
}