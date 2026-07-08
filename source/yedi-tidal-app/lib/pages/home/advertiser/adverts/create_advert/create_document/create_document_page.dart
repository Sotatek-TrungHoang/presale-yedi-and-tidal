import 'package:flutter/material.dart';
import 'package:yedi_app/pages/home/advertiser/adverts/create_advert/create_document/create_document_view.dart';

class CreateDocumentPage extends StatelessWidget {
  const CreateDocumentPage({super.key});

  static const name = "advertiser-create-document";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Document"),
      ),
      body: CreateDocumentView(),
    );
  }
}
