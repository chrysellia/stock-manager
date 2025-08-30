// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Gestion Stock Épicerie';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Entrez votre email';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordHint => 'Entrez votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get or => 'OU';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get emailRequired => 'email requis';

  @override
  String get emailInvalid => 'Veuillez entrer un email valide';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get loading => 'Chargement...';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get search => 'Rechercher...';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get error => 'Une erreur est survenue';
}
