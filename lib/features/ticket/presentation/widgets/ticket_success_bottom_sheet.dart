import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class TicketSuccessBottomSheet extends StatelessWidget {
  final String ticketId;
  final VoidCallback onReturnHome;
  final VoidCallback onViewTickets;

  const TicketSuccessBottomSheet({
    super.key,
    required this.ticketId,
    required this.onReturnHome,
    required this.onViewTickets,
  });

  Future<void> _copyTicketId(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: ticketId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket ID copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520, // Increased height to accommodate the new button
      decoration: BoxDecoration(
        color: AppColor.kMainBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 42,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE1E1E4),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          // Success Illustration
          Container(
            width: 140,
            height: 140,
            margin: const EdgeInsets.only(top: 48, bottom: 24),
            decoration: BoxDecoration(
              color: AppColor.kCompletedGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColor.kCompletedGreen,
            ),
          ),

          // Success Title and Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  'Success  🎉',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F1121),
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your ticket has been created successfully!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF67697A),
                    height: 1.6,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Our support team will get back to you shortly',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF67697A),
                    height: 1.6,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ticket ID Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3F3FA), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ticketId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF67697A),
                        height: 1.3,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copyTicketId(context),
                    child: Icon(
                      Icons.copy,
                      size: 24,
                      color: const Color(0xFF67697A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Return to Homepage Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onReturnHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Return to Homepage',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 12),
          // // My Tickets Button
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: SizedBox(
          //     width: double.infinity,
          //     height: 52,
          //     child: OutlinedButton(
          //       onPressed: onViewTickets,
          //       style: OutlinedButton.styleFrom(
          //         side: const BorderSide(
          //           color: AppColor.kPrimaryColor,
          //           width: 1,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //       ),
          //       child: const Text(
          //         'My Tickets',
          //         style: TextStyle(
          //           fontSize: 14,
          //           fontWeight: FontWeight.w600,
          //           height: 1.3,
          //           color: AppColor.kPrimaryColor,
          //           fontFamily: 'GeneralSans',
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          const Spacer(),

          // Home Indicator
          Container(
            height: 34,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1121),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
