import 'package:flutter/material.dart';
import 'package:yedi_app/modules/common/models/document_model.dart';
import 'package:yedi_app/ui/adverts/advert_document_tile.dart';
import 'package:yedi_app/ui/spacer.dart';

class AdvertDocumentsList extends StatelessWidget {
  final List<DocumentModel> documents;

  const AdvertDocumentsList({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Documents",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        VSpacer(12),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: documents.length,
          separatorBuilder: (context, index) => VSpacer(20),
          itemBuilder: (context, index) {
            final document = documents[index];
            return AdvertDocumentTile(
                key: ValueKey(document.upload.url),
                title: document.title,
                url: document.upload.url);
          },
        )
      ],
    );
  }
}
