import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

// Custom linkifier for phone numbers
class PhoneNumberLinkifier extends Linkifier {
  static final _phoneRegex = RegExp(r'(\+?\d[\d\s-]{7,}\d)');

  const PhoneNumberLinkifier();

  @override
  List<LinkifyElement> parse(
      List<LinkifyElement> elements, LinkifyOptions options) {
    final List<LinkifyElement> list = [];
    for (final element in elements) {
      if (element is TextElement) {
        final matches = _phoneRegex.allMatches(element.text);
        if (matches.isEmpty) {
          list.add(element);
          continue;
        }

        int start = 0;
        for (final match in matches) {
          if (match.start != start) {
            list.add(TextElement(element.text.substring(start, match.start)));
          }
          final phone = match.group(0)!;
          list.add(LinkableElement(phone, phone));
          start = match.end;
        }
        if (start < element.text.length) {
          list.add(TextElement(element.text.substring(start)));
        }
      } else {
        list.add(element);
      }
    }
    return list;
  }
}

// Custom linkifier for Instagram handles
class InstagramHandleLinkifier extends Linkifier {
  static final _handleRegex = RegExp(r'@([a-zA-Z0-9_.]+)');

  const InstagramHandleLinkifier();

  @override
  List<LinkifyElement> parse(
      List<LinkifyElement> elements, LinkifyOptions options) {
    final List<LinkifyElement> list = [];
    for (final element in elements) {
      if (element is TextElement) {
        final matches = _handleRegex.allMatches(element.text);
        if (matches.isEmpty) {
          list.add(element);
          continue;
        }

        int start = 0;
        for (final match in matches) {
          if (match.start != start) {
            list.add(TextElement(element.text.substring(start, match.start)));
          }
          final handle = match.group(0)!;
          list.add(LinkableElement(handle, handle));
          start = match.end;
        }
        if (start < element.text.length) {
          list.add(TextElement(element.text.substring(start)));
        }
      } else {
        list.add(element);
      }
    }
    return list;
  }
}

// Helper widget for detail rows
Widget _buildDetailRow(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  Widget? trailing,
  VoidCallback? onLongPress,
}) {
  final theme = Theme.of(context);

  return GestureDetector(
    onLongPress: onLongPress,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Linkify(
                  text: value,
                  style: theme.textTheme.bodyMedium,
                  linkStyle: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  options: const LinkifyOptions(humanize: false),
                  linkifiers: const [
                    UrlLinkifier(),
                    EmailLinkifier(),
                    PhoneNumberLinkifier(),
                    InstagramHandleLinkifier(),
                  ],
                  onOpen: (link) async {
                    String url = link.url;
                    if (RegExp(r'^\+?\d').hasMatch(url)) {
                      // Phone number
                      url = "tel:$url";
                    } else if (url.startsWith('@')) {
                      // Instagram handle
                      url = "https://instagram.com/${url.substring(1)}";
                    }
                    final uri = Uri.parse(url);
                    if (!await launchUrl(uri,
                        mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    ),
  );
}
