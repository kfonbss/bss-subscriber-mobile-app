import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Color _gray = Color(0xFFF3F3FA);

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      scaffoldColor: Colors.white,
      onBackPressed: () => Navigator.pop(context),
      title: 'Notification',
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.settings_outlined, // Placeholder icon
            color: Colors.black, // #0F1121
            size: 24,
          ),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 30,
          children: [
            Card(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: _gray,
              child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  color: Colors.white,
                ),

                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                indicatorWeight: 0.0,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade500,
                padding: EdgeInsets.all(5),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: "Notification"),
                  Tab(text: "Promo & Offer"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                spacing: 16,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _gray,
                                        ),
                                        // Inner icon (Vector)
                                        child: Center(
                                          child: Image.asset(
                                            'assets/icons/glob.png',
                                            height: 20,
                                            width: 20,
                                            color: AppColor.kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: const Text(
                                                    'Account Verification',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      height: 1.3,
                                                      color: Color(0xFF0F1121),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  '9:41 Am',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                    color: Color(0xFF67697A),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                            const Text(
                                              'Please verify your account to gift an package to your friend.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 1.6,
                                                color: Color(0xFF67697A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1, color: _gray),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yesterday',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                  Image.asset(
                                    'assets/images/delete_image__1.png',
                                  ),
                                  Row(
                                    spacing: 12,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _gray,
                                        ),

                                        child: Center(
                                          child: Image.asset(
                                            'assets/icons/offer_promo.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Best Deal Unlimited Call! 🥰',
                                                    style: TextStyle(
                                                      fontFamily: 'General Sans',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      height: 1.3,
                                                      color: Color(0xFF0F1121),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Text(
                                                  '9:41 AM',
                                                  style: TextStyle(
                                                    fontFamily: 'General Sans',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                    color: Color(
                                                      0xFF67697A,
                                                    ), // Grey/500 - Main
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Don't miss out on this incredible deal! We're excited to offer you unlimited calling to any operator, 24 hours a day. That's right, you can chat with your loved ones or colleagues anytime you want without worrying about time or cost limitations.",
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 1.6,
                                                // line-height: 160%
                                                color: Color(0xFF67697A),
                                              ),
                                              maxLines: 6,
                                              // Adjusted to roughly match the 114px height (6 lines * 19px/line)
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Get it Now',
                                              style: TextStyle(
                                                fontFamily: 'General Sans',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                height: 1.3,
                                                color: Color(
                                                  0xFF8D0247,
                                                ), // Main color
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1, color: _gray),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
