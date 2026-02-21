import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

// ── Constants ────────────────────────────────────────────────
const kMaroon  = Color(0xFF8D0247);
const kBg      = Color(0xFFF2EFE7);
const kYellow  = Color(0xFFFDE933);
const kGreen   = Color(0xFF27B73E);
const kGray    = Color(0xFF717171);
const kDark    = Color(0xFF0F1121);
void main() {
  runApp(MaterialApp(home: Scaffold(body: const HomeScreen())));
}
// ── Home Screen ──────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Maroon Header ────────────────────────────
              _buildHeader(),
              SizedBox(height: 16.h),

              // ── Active Plan Card ─────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildActivePlanCard(),
              ),
              SizedBox(height: 16.h),

              // ── Quick Actions ────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildQuickActions(),
              ),
              SizedBox(height: 32.h),

              // ── Plan Change Section ──────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildPlanChangeSection(),
              ),
              SizedBox(height: 32.h),

              // ── Services Offered ─────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildServicesSection(),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 314.h,
      decoration: const BoxDecoration(
        color: kMaroon,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -60.w, top: 97.h,
            child: Container(
              width: 148.w, height: 148.w,
              decoration: const BoxDecoration(
                color: Color(0xFF9F004F),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -167.w, top: 107.h,
            child: Container(
              width: 342.w, height: 342.w,
              decoration: const BoxDecoration(
                color: Color(0xFF9F004F),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: logo + actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // KFON Logo text placeholder
                    Text(
                      'KFON',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.notifications_outlined, color: Colors.white, size: 24.sp),
                        SizedBox(width: 12.w),
                        Container(
                          width: 42.w, height: 42.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white24,
                          ),
                          child: Icon(Icons.person, color: Colors.white, size: 22.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Wallet Balance
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹ 38,200',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 0.92,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: kYellow,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Top up',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: kDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Updated 03 Nov 2025',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Active Plan Card ──────────────────────────────────────
  Widget _buildActivePlanCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
      ),
      child: Column(
        children: [
          // Plan name + days left
          Row(
            children: [
              Container(
                width: 38.w, height: 38.w,
                decoration: const BoxDecoration(color: Color(0xFFA70053), shape: BoxShape.circle),
                child: Icon(Icons.wifi, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Combo Plan',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
                    Text('Active until Aug 25, 2025',
                        style: TextStyle(fontSize: 10.sp, color: const Color(0xFF333333).withOpacity(0.8))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(color: kYellow, borderRadius: BorderRadius.circular(50)),
                child: Text('20 Days left',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: kDark)),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Stats row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _PlanStat(label: 'Amount',  value: '₹499'),
                _PlanStat(label: 'Speed',   value: '100 Mbps'),
                _PlanStat(label: 'FPU',     value: 'Unlimited'),
                _PlanStat(label: 'Usage',   value: '21 GB / 100 GB'),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kMaroon),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  child: Text('+2 Pack Active',
                      style: TextStyle(fontSize: 12.sp, color: kMaroon, fontWeight: FontWeight.w500)),
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMaroon,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    elevation: 0,
                  ),
                  child: Text('View Usage',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {'color': const Color(0xFF14B8A6), 'icon': Icons.smartphone, 'label': 'Top Up'},
      {'color': const Color(0xFFF97316), 'icon': Icons.swap_horiz,  'label': 'Transactions'},
      {'color': const Color(0xFFEF4949), 'icon': Icons.receipt_long,'label': 'Invoice'},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 100.h,
              decoration: BoxDecoration(
                color: a['color'] as Color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46.w, height: 46.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 4, offset: const Offset(0, 4))],
                    ),
                    child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22.sp),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    a['label'] as String,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Plan Change Section ───────────────────────────────────
  Widget _buildPlanChangeSection() {
    return Column(
      children: [
        // Title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Plan Change',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF121212))),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text('See all',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: kMaroon)),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward, color: kMaroon, size: 16.sp),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Plan cards
        _buildPlanCard(title: 'Internet Extra Combo Plus'),
        SizedBox(height: 16.h),
        _buildPlanCard(title: 'Mega Extra Plus'),
      ],
    );
  }

  Widget _buildPlanCard({required String title}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
      ),
      child: Column(
        children: [
          // Plan title row
          Row(
            children: [
              Container(
                width: 32.w, height: 32.w,
                decoration: const BoxDecoration(color: kBg, shape: BoxShape.circle),
                child: Icon(Icons.wifi, color: kMaroon, size: 16.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(title,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: kDark)),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Stats
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                _PlanStat(label: 'Data',     value: '100 GB'),
                _PlanStat(label: 'Speed',    value: '100 Mbps'),
                _PlanStat(label: 'FPU',      value: 'Unlimited'),
                _PlanStat(label: 'Validity', value: '30 Days'),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Bottom row: price + choose
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: kMaroon, borderRadius: BorderRadius.circular(9)),
                child: Text('₹ 182',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kMaroon),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                ),
                child: Text('Choose Plan',
                    style: TextStyle(fontSize: 12.sp, color: kMaroon, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Services Offered ──────────────────────────────────────
  Widget _buildServicesSection() {
    final services = [
      {'title': 'Fiber to Home (FTTH)',       'icon': Icons.home,                  'count': '1000', 'today': '102 today'},
      {'title': 'Internet Leased line (IIL)', 'icon': Icons.computer,              'count': '1000', 'today': '102 today'},
      {'title': 'Dark Fiber for Leased (DFL)','icon': Icons.cloud,                 'count': '1000', 'today': '102 today'},
      {'title': 'Co-Location',                'icon': Icons.location_on,           'count': '1000', 'today': '102 today'},
      {'title': 'WiFi Services',              'icon': Icons.wifi,                  'count': '1000', 'today': '102 today'},
      {'title': 'Over-the-Top (OTT)',         'icon': Icons.phone_android,         'count': '1000', 'today': '102 today'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services Offered',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: kDark)),
        SizedBox(height: 16.h),

        // 2-column grid
        ...List.generate((services.length / 2).ceil(), (row) {
          final left  = services[row * 2];
          final right = row * 2 + 1 < services.length ? services[row * 2 + 1] : null;
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                Expanded(child: _ServiceCard(service: left)),
                SizedBox(width: 19.w),
                Expanded(child: right != null ? _ServiceCard(service: right) : const SizedBox()),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_filled,  'label': 'Home'},
      {'icon': Icons.wifi,         'label': 'Broadband'},
    ];

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.11), blurRadius: 19, offset: const Offset(0, -1))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left items
              _NavItem(icon: Icons.home_filled, label: 'Home',      active: _navIndex == 0, onTap: () => setState(() => _navIndex = 0)),
              _NavItem(icon: Icons.wifi,        label: 'Broadband', active: _navIndex == 1, onTap: () => setState(() => _navIndex = 1)),
              SizedBox(width: 56.w), // FAB space
              _NavItem(icon: Icons.receipt,     label: 'FAQ',       active: _navIndex == 2, onTap: () => setState(() => _navIndex = 2)),
              _NavItem(icon: Icons.person,      label: 'Profile',   active: _navIndex == 3, onTap: () => setState(() => _navIndex = 3)),
            ],
          ),
          // FAB
          Positioned(
            top: -16.h,
            child: Container(
              width: 56.w, height: 56.w,
              decoration: BoxDecoration(
                color: kMaroon,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF005D5D).withOpacity(0.24), blurRadius: 17, offset: const Offset(0, 7))],
              ),
              child: Icon(Icons.headphones, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────

class _PlanStat extends StatelessWidget {
  final String label;
  final String value;
  const _PlanStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 8.sp,  color: kGray)),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: kDark)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service['title'] as String,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF151515)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service['count'] as String,
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500, color: const Color(0xFF121212))),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward, color: kGreen, size: 10.sp),
                      SizedBox(width: 2.w),
                      Text(service['today'] as String,
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: kGreen)),
                    ],
                  ),
                ],
              ),
              Icon(Icons.arrow_forward, size: 24.sp, color: const Color(0xFF292D32)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? kMaroon : const Color(0xFF262626), size: 21.sp),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? kMaroon : const Color(0xFF262626),
              )),
          SizedBox(height: 4.h),
          if (active)
            Container(width: 4.w, height: 3.h, decoration: BoxDecoration(color: kMaroon, borderRadius: BorderRadius.circular(87))),
        ],
      ),
    );
  }
}