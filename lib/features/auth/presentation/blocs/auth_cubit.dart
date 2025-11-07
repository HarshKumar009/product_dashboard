import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(Unauthenticated());

  final String _correctUsername = 'harsh';
  final String _correctPassword = 'harsh';

  void login(String username, String password) {
    if (username == _correctUsername && password == _correctPassword) {
      emit(Authenticated());
    } else {
      emit(const AuthError('Invalid username or password'));
      Future.delayed(const Duration(seconds: 2), () => emit(Unauthenticated()));
    }
  }

  void logout() {
    emit(Unauthenticated());
  }
}