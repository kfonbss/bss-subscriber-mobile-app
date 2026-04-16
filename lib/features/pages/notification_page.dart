import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const Color _gray = AppColor.kIconContainerGrey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      scaffoldColor: Colors.white,
      onBackPressed: () => Navigator.pop(context),
      title: l10n.notification,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.settings_outlined,
            color: Colors.black,
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
                unselectedLabelColor: AppColor.kMediumGrey,
                padding: EdgeInsets.all(5),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: l10n.notification),
                  Tab(text: l10n.promoAndOffer),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Notification Tab ──────────────────────────────────
                  Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recently,
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
                                                  child: Text(
                                                    l10n.accountVerification,
                                                    style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 14,
                                                      height: 1.3,
                                                      color: AppColor.kTextSecondaryDark,
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
                                                    color: AppColor.kSlateGrey,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              l10n.accountVerificationMessage,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 1.6,
                                                color: AppColor.kSlateGrey,
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

                  // ── Promo & Offer Tab ─────────────────────────────────
                  Column(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.yesterday,
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
                              l10n.clearAll,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColor.kFailedRed,
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
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    l10n.bestDealTitle,
                                                    style: TextStyle(
                                                      fontFamily: 'GeneralSans',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      height: 1.3,
                                                      color: AppColor.kTextSecondaryDark,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Text(
                                                  '9:41 AM',
                                                  style: TextStyle(
                                                    fontFamily: 'GeneralSans',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                    color: AppColor.kSlateGrey,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              l10n.bestDealMessage,
                                              style: TextStyle(
                                                fontFamily: 'GeneralSans',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 1.6,
                                                color: AppColor.kSlateGrey,
                                              ),
                                              maxLines: 6,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              l10n.getItNow,
                                              style: TextStyle(
                                                fontFamily: 'GeneralSans',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                height: 1.3,
                                                color: AppColor.kPrimaryColor,
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
