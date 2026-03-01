import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    throw Exception('Could not launch $url');
  }
}

Future<void> openCoffee() => openExternalUrl('https://buymeacoffee.com/4miers');

Future<void> openBugReport() => openExternalUrl(
  'https://github.com/4mierS/picksy/issues/new?template=bug_report.yml',
);

Future<void> openFeatureRequest() => openExternalUrl(
  'https://github.com/4mierS/picksy/issues/new?template=feature_request.yml',
);

Future<void> openGithubIssues() =>
    openExternalUrl('https://github.com/4mierS/picksy/issues');

Future<void> openPrivacyPolicy() =>
    openExternalUrl('https://4miers.github.io/picksy/privacy');

Future<void> openImprint() =>
    openExternalUrl('https://4miers.github.io/picksy/imprint');

Future<void> openTermsOfService() =>
    openExternalUrl('https://4miers.github.io/picksy/terms-of-service');

Future<void> openRateApp() =>
    openExternalUrl('https://github.com/4mierS/picksy');

Future<void> shareApp() => Share.share(
  'Try Picksy — the smart random decision app!\nhttps://github.com/4mierS/picksy',
  subject: 'Check out Picksy!',
);
