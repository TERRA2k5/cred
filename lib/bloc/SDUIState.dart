import 'package:credd/bloc/SDUIEvent.dart';
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
  final StatementTab activeTab;

  const SDUILoaded(
    this.items, {
    this.activeTab = StatementTab.totalDue,
  });

  SDUILoaded copyWith({
    List<SDUIModel>? items,
    StatementTab? activeTab,
  }) {
    return SDUILoaded(
      items ?? this.items,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [items, activeTab];
}

class SDUIError extends SDUIState {
  final String message;

  const SDUIError(this.message);

  @override
  List<Object?> get props => [message];
}
