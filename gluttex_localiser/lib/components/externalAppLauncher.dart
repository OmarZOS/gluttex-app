import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchExternalApp(
    BuildContext context, String type, String value) async {
  final lowercaseType = type.toLowerCase();
  String url = value;
  Uri? uri;

  try {
    if (lowercaseType.contains('phone')) {
      // Open in phone app
      final phoneNumber = value.replaceAll(RegExp(r'[^0-9+]'), '');
      uri = Uri.parse('tel:$phoneNumber');
    } else if (lowercaseType.contains('email')) {
      // Open in email app
      uri = Uri.parse('mailto:$value');
    } else if (lowercaseType.contains('facebook')) {
      // Try to open in Facebook app first
      final username =
          value.replaceAll('https://www.facebook.com/', '').replaceAll('@', '');
      uri = Uri.parse(
          'fb://facewebmodal/f?href=https://www.facebook.com/$username');
    } else if (lowercaseType.contains('instagram')) {
      // Try to open in Instagram app first
      final username = value
          .replaceAll('https://www.instagram.com/', '')
          .replaceAll('@', '');
      uri = Uri.parse('instagram://user?username=$username');
    } else if (lowercaseType.contains('twitter')) {
      // Try to open in Twitter app first
      final username =
          value.replaceAll('https://twitter.com/', '').replaceAll('@', '');
      uri = Uri.parse('twitter://user?screen_name=$username');
    } else if (lowercaseType.contains('whatsapp')) {
      // Open in WhatsApp
      final phoneNumber = value.replaceAll(RegExp(r'[^0-9+]'), '');
      uri = Uri.parse('https://wa.me/$phoneNumber');
    } else if (lowercaseType.contains('tiktok')) {
      // Try to open in TikTok app
      final username =
          value.replaceAll('https://www.tiktok.com/', '').replaceAll('@', '');
      uri = Uri.parse('snssdk1233://user/profile/$username');
    } else {
      // Default website handling
      if (!value.startsWith('http')) {
        url = value;
      }
      uri = Uri.parse(url);
    }

    if (uri != null) {
      // Try native app first
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      // Fallback to browser if app not installed
      else if (lowercaseType.contains('facebook')) {
        await launchUrl(
          Uri.parse(
              'https://www.facebook.com/${value.replaceAll('https://www.facebook.com/', '').replaceAll('@', '')}'),
          mode: LaunchMode.externalApplication,
        );
      } else if (lowercaseType.contains('instagram')) {
        await launchUrl(
          Uri.parse(
              'https://www.instagram.com/${value.replaceAll('https://www.instagram.com/', '').replaceAll('@', '')}'),
          mode: LaunchMode.externalApplication,
        );
      } else if (lowercaseType.contains('tiktok')) {
        await launchUrl(
          Uri.parse(
              'https://www.tiktok.com/@${value.replaceAll('https://www.tiktok.com/', '').replaceAll('@', '')}'),
          mode: LaunchMode.externalApplication,
        );
      } else if (lowercaseType.contains('website')) {
        // Handle website URLs specifically
        if (!value.startsWith('http')) {
          uri = Uri.parse('https://$value');
        } else {
          uri = Uri.parse(value);
        }

        // First try to launch directly
        if (await canLaunchUrl(uri!)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }

        // If failed, try adding www prefix if missing
        if (!value.contains('www.')) {
          final modifiedUri =
              Uri.parse(value.replaceFirst('https://', 'https://www.'));
          if (await canLaunchUrl(modifiedUri)) {
            await launchUrl(modifiedUri, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }
    }
  } catch (e) {
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Could not open: $value'),
    //       backgroundColor: Theme.of(context).colorScheme.error,
    //     ),
    //   );
    // }
  }
}
