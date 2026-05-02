import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/form_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

class EnquiryFormList extends StatelessWidget {
  const EnquiryFormList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return FormAppBar(
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SecondaryButton(
              label: l10n.home,
              onClicked: () =>
                  Navigator.pushNamed(context, AppRoutes.homeEnquiryForm),
            ),
            SecondaryButton(
              label: l10n.corporate,
              onClicked: () =>
                  Navigator.pushNamed(context, '/corporate_enquiry_form'),
            ),
            SecondaryButton(
              label: l10n.government,
              onClicked: () =>
                  Navigator.pushNamed(context, AppRoutes.governmentEnquiryForm),
            ),
            SecondaryButton(
              label: l10n.bplEnquiry,
              onClicked: () =>
                  Navigator.pushNamed(context, AppRoutes.bplEnquiryForm),
            ),
            SecondaryButton(
              label: l10n.lnpEnquiry,
              onClicked: () =>
                  Navigator.pushNamed(context, AppRoutes.lnpEnquiryForm),
            ),
            SecondaryButton(
              label: l10n.agnpEnquiry,
              onClicked: () =>
                  Navigator.pushNamed(context, AppRoutes.agnpEnquiryForm),
            ),
            SecondaryButton(
              label: l10n.darkFibreEnquiry,
              onClicked: () =>
                  Navigator.pushNamed(context, AppRoutes.darkFibreEnquiryForm),
            ),
          ],
        ),
      ),
    );
  }
}
