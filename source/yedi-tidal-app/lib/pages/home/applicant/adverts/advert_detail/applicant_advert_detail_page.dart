import 'package:flutter/material.dart';
import 'package:yedi_app/pages/home/applicant/adverts/advert_detail/applicant_advert_detail_view.dart';

class ApplicantAdvertDetailPage extends StatelessWidget {
  const ApplicantAdvertDetailPage({required this.id, super.key});

  final int id;

  static const name = 'applicant-advert-detail';

  @override
  Widget build(BuildContext context) {
    return ApplicantAdvertDetailView(id: id);
  }
}
