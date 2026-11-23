import 'package:equatable/equatable.dart';

enum StatementTab { totalDue, recentSpends }

abstract class SDUIEvent extends Equatable {
  const SDUIEvent();

  @override
  List<Object?> get props => [];
}

class FetchSDUIData extends SDUIEvent {
  const FetchSDUIData();
}

class SwitchStatementTab extends SDUIEvent {
  final StatementTab tab;

  const SwitchStatementTab(this.tab);

  @override
  List<Object?> get props => [tab];
}
