import 'package:credd/models/SDUI_model.dart';
import 'package:equatable/equatable.dart';

abstract class SDUIState extends Equatable {
  const SDUIState();

  @override
  List<Object?> get props => [];
}

class SDUILoading extends SDUIState {
  const SDUILoading();
}

class SDUILoaded extends SDUIState {
  final List<SDUIModel> items;

  const SDUILoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class SDUIError extends SDUIState {
  final String message;

  const SDUIError(this.message);

  @override
  List<Object?> get props => [message];
}
