import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String phone) async {
  Uri url = Uri(scheme: "tel", path: phone);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    return;
  }
}
