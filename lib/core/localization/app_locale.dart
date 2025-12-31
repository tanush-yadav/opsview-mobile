import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  english('en', 'English');
  // TODO: Add other languages later

  const AppLanguage(this.code, this.displayName);

  final String code;
  final String displayName;
}

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.english;

  void setLanguage(AppLanguage language) {
    state = language;
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageNotifier, AppLanguage>(AppLanguageNotifier.new);
