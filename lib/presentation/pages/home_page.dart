import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:readmore/readmore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final Color kLightPrimaryColor = Color(0xFFFFF5E3);
  final Color kYellowAccent = Color(0xFFF4F19A);
  final Color kLightGrey = Color(0xFFCBCBCB);
  final Color kDarkText = Color(0xFF0F1121);
  final Color kMediumGreyText = Color(0xFF67697A);
  final List<Map<String, dynamic>> services = [
    {'title': 'Fiber to Home (FTTH)', 'icon': 'thunder.png'},
    {'title': 'Internet Leased Line (ILL)', 'icon': 'internet_leased_line.png'},
    {'title': 'Dark Fiber for Leased (DFL)', 'icon': 'dark_fiber.png'},
    {'title': 'Co-Location', 'icon': 'ip_location.png'},
    {'title': 'WiFi Services', 'icon': 'wifi.png'},
    {'title': 'Over-the-Top (OTT)', 'icon': 'ott.png'},
  ];

  Widget _buildServiceCard({
    required Color color,
    required String icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset('assets/icons/$icon'),
              ),
            ),
            const SizedBox(height: 10),
            // Label
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOfferedCard({
    required String icon,
    required String title,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icon
              Image.asset('assets/icons/$icon', height: 32, width: 32),
              const SizedBox(width: 8),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.65,
                    // equivalent to 20px line height
                    color: kDarkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String data,
    required String price,
    required String description,
  }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFCBCBCB), width: 1.0),
        borderRadius: BorderRadius.circular(16.0),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.asset(
                          'assets/icons/glob.png',
                          color: AppColor.kPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: kDarkText,
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/ribon_price_tag.svg',
                      width: 64,
                      height: 28,
                    ),
                    Text(
                      '₹ $price',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              data,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: kDarkText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    spacing: 15,
                    children: [
                      Row(
                        children: [
                          Align(
                            widthFactor: 0.5,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                'assets/icons/prime.png',
                              ),
                            ),
                          ),
                          Align(
                            widthFactor: 0.5,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                'assets/icons/netflix.png',
                              ),
                            ),
                          ),
                          Align(
                            widthFactor: 0.5,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                'assets/icons/zeetv.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ReadMoreText(
                          description,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: kMediumGreyText,
                          ),
                          trimMode: TrimMode.Line,
                          trimLines: 1,
                          colorClickableText: AppColor.kPrimaryColor,

                          trimCollapsedText: 'Show more',
                          trimExpandedText: 'Show less',
                          moreStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColor.kPrimaryColor
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Choose Plan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColor.kPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(height: 250, color: AppColor.kPrimaryColor),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Makes the container circular
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 4, // Border thickness
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://picsum.photos/seed/picsum/200/300', // Your image URL
                          ),
                          fit:
                              BoxFit.cover, // How the image fills the container
                        ),
                      ),
                    ),
                    Text(
                      'Albert John',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(218, 218, 218, 0.22),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.white.withAlpha(50), // Color of the border
                      width: 1.0, // Width of the border
                    ),
                  ),
                  // Use Padding for the inner content's left/right spacing
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'Wallet',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '₹1000',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                                color: Color(0xFFFDE933),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Top up',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: const BorderSide(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      width: 2.0,
                    ),
                  ),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFF8F8F8),
                          ),
                          margin: const EdgeInsets.all(6.0),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '100 Mbps',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '(Unlimited)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      color: Color.fromRGBO(51, 51, 51, 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDE933),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  '20 Days left',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 14,
                            bottom: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColor.kPrimaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'assets/icons/glob.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Combo Plan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        Text(
                                          'Active until Aug 25, 2025',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                            color: Color.fromRGBO(
                                              51,
                                              51,
                                              51,
                                              0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // +3 Pack button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(80),
                                    ),
                                    child: const Text(
                                      '+ 3 Pack',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 17),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                // Adjust the radius as needed
                                child: LinearProgressIndicator(
                                  minHeight: 6,
                                  value: 0.7, // Example progress value
                                  backgroundColor: Color(0xFFE3E3E3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColor.kPrimaryColor,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '21 GB Available / 100 GB',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    'View Usage',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: AppColor.kPrimaryColor,
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
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10,
                  children: [
                    _buildServiceCard(
                      color: Color(0xFFEC4899),
                      icon: 'recharge_icon.png',
                      label: 'Recharge',
                    ),
                    _buildServiceCard(
                      color: Color(0xFFF59E0B),
                      icon: 'money_icon.png',
                      label: 'Transactions',
                    ),
                    _buildServiceCard(
                      color: Color(0xFF3B82F6),
                      icon: 'invoice_icon.png',
                      label: 'Invoice',
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side: Plan Change title
                    const Text(
                      'Plan Change',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        height: 22 / 16,
                        color: Color(0xFF121212),
                      ),
                    ),
                    // Right side: "See all" link
                    InkWell(
                      onTap: () {
                        // Add your navigation logic here
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Wrap content
                        children: [
                          Text(
                            'See all',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                              height: 19 / 14,
                              color: AppColor.kPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // You'll need an icon for the arrow
                          Icon(
                            Icons.arrow_right_alt,
                            size: 16,
                            color: AppColor.kPrimaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    _buildPlanCard(
                      title: 'Internet Extra Combo Plus',
                      data: '500 GB / 30 days',
                      price: '182',
                      description: '30+ OTT, Unlimited Internet More iufdibfidbfiudbifubdiubfiudbiufbdiufbiudbfiudbuifbdibui..',
                    ),
                    SizedBox(height: 16),
                    _buildPlanCard(
                      title: 'Mega Extra Plus',
                      data: '1000 GB / 30 days',
                      price: '400',
                      description: '30+ OTT, Unlimited Internet More..',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Services Offered',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Color(0xFF121212),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Grid of Service Cards
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio:
                                  2.2, // Adjust to control card height
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return _buildServiceOfferedCard(
                            title: services[index]['title'],
                            icon: services[index]['icon'],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
