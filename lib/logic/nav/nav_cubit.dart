import 'package:flutter_bloc/flutter_bloc.dart';

class NavCubit extends Cubit<int> {
  NavCubit() : super(0); // Default index 0 (Home)

  void updateIndex(int index) => emit(index);
}