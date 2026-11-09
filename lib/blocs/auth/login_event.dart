abstract class LoginEvent {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });
}

class GoogleLoginSubmitted extends LoginEvent {
  const GoogleLoginSubmitted();
}
