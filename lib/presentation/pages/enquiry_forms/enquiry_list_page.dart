import 'package:flutter/material.dart';
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
                  () => Navigator.pushNamed(context, '/home_enquiry_form'),
            ),
            SecondaryButton(
              label: 'Corporate',
              onClicked:
                  () => Navigator.pushNamed(context, '/corporate_enquiry_form'),
            ),
            SecondaryButton(
              label: 'Government',
              onClicked:
                  () => Navigator.pushNamed(context, '/government_enquiry_form'),
            ),
            SecondaryButton(
              label: 'BPL Enquiry',
              onClicked:
                  () => Navigator.pushNamed(context, '/bpl_enquiry_form'),
            ),
            SecondaryButton(
              label: 'LNP Enquiry',
              onClicked:
                  () => Navigator.pushNamed(context, '/lnp_enquiry_form'),
            ),
            SecondaryButton(
              label: 'AGNP Enquiry',
              onClicked:
                  () => Navigator.pushNamed(context, '/agnp_enquiry_form'),
            ),
            SecondaryButton(
              label: 'Dark Fibre Enquiry',
              onClicked:
                  () =>
                      Navigator.pushNamed(context, '/dark_fibre_enquiry_form'),
            ),
          ],
        ),
      ),
    );
  }
}
