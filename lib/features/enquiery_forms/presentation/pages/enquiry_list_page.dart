import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/presentation/ui_component/form_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';

class EnquiryFormList extends StatelessWidget {
  const EnquiryFormList({super.key});

  @override
  Widget build(BuildContext context) {
    return FormAppBar(
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SecondaryButton(
              label: 'Home',
              onClicked:
                  () => Navigator.pushNamed(context, AppRoutes.homeEnquiryForm),
            ),
            SecondaryButton(
              label: 'Corporate',
              onClicked:
                  () => Navigator.pushNamed(context, '/corporate_enquiry_form'),
            ),
            SecondaryButton(
              label: 'Government',
              onClicked:
                  () => Navigator.pushNamed(context, AppRoutes.governmentEnquiryForm),
            ),
            SecondaryButton(
              label: 'BPL Enquiry',
              onClicked:
                  () => Navigator.pushNamed(context, AppRoutes.bplEnquiryForm),
            ),
            SecondaryButton(
              label: 'LNP Enquiry',
              onClicked:
                  () => Navigator.pushNamed(context, AppRoutes.lnpEnquiryForm),
            ),
            SecondaryButton(
              label: 'AGNP Enquiry',
              onClicked:
                  () => Navigator.pushNamed(context, AppRoutes.agnpEnquiryForm),
            ),
            SecondaryButton(
              label: 'Dark Fibre Enquiry',
              onClicked:
                  () =>
                      Navigator.pushNamed(context, AppRoutes.darkFibreEnquiryForm),
            ),
          ],
        ),
      ),
    );
  }
}
