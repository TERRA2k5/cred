import 'package:equatable/equatable.dart';

abstract class SDUIEvent extends Equatable {
  const SDUIEvent();

  @override
  List<Object?> get props => [];
}

class FetchSDUIData extends SDUIEvent {
  const FetchSDUIData();
}
