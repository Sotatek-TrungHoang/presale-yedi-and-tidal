import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yedi_app/ui/spacer.dart';
import 'package:yedi_app/ui/theme/app_theme.dart';

class AdvertDocumentTile extends StatelessWidget {
  const AdvertDocumentTile(
      {super.key,
      required this.title,
      required this.url,
      this.enabled = true,
      this.onDeletePressed});

  final String title;
  final String url;
  final void Function()? onDeletePressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            // color: appColours.canvasBackground,
            borderRadius: BorderRadius.all(Radius.circular(themeBorderRadius)),
            color: appColours.canvasBackground),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file,
            ),
            HSpacer(20),
            Expanded(
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            HSpacer(20),
            if (onDeletePressed != null)
              IconButton(
                  onPressed: enabled ? onDeletePressed : null,
                  icon: Icon(Icons.delete)),
            IconButton(
                onPressed: enabled
                    ? () {
                        launchUrlString(url);
                      }
                    : null,
                icon: Icon(Icons.chevron_right)),
          ],
        ));
  }
}
