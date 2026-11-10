import 'package:url_launcher/url_launcher.dart';

// Opens the phone dialer or WhatsApp. Screens only call these 2 methods.
class ContactHelper {
  // Keep only the digits: '0300-123 4567' -> '03001234567'
  static String _digits(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Pakistan style -> international style for WhatsApp.
  // '03001234567' -> '923001234567'
  static String _international(String phone) {
    var d = _digits(phone);
    if (d.startsWith('00')) {
      d = d.substring(2); // '0092300...' -> '92300...'
    } else if (d.startsWith('0')) {
      d = '92${d.substring(1)}'; // '0300...' -> '92300...'
    }
    return d; // already '92300...' stays as it is
  }

  // Opens the dialer. Returns true if it worked.
  static Future<bool> call(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: _digits(phone));
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  // Opens WhatsApp with a message. Returns true if it worked.
  static Future<bool> whatsapp(String phone, String message) async {
    try {
      final text = Uri.encodeComponent(message);
      final uri = Uri.parse('https://wa.me/${_international(phone)}?text=$text');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}