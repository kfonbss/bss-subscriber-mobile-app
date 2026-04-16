import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class Language {
  final String name;
  final String flagAsset;
  final String code;

  Language({required this.name, required this.flagAsset, required this.code});
}

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'English';
  String _searchQuery = '';

  final List<Language> _allLanguages = [
    Language(name: 'English', flagAsset: '', code: 'en'),
    Language(name: 'Indonesia', flagAsset: '', code: 'id'),
    Language(name: 'Melayu', flagAsset: '', code: 'ms'),
    Language(name: 'Japanese', flagAsset: '', code: 'ja'),
    Language(name: 'Chinese', flagAsset: '', code: 'zh'),
  ];

  // ── Static styles for the search bar ────────────────────────────────────────
  static final _searchDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.w)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kIconContainerGrey, width: 1.w),
    ),
  );
  static final _searchTextStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
  );
  static final _searchHintStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kSlateGrey,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
  );
  static const _searchIconColorFilter =
      ColorFilter.mode(AppColor.kSlateGrey, BlendMode.srcIn);
  static final _sectionHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  List<Language> get _filteredLanguages {
    if (_searchQuery.isEmpty) return _allLanguages;
    return _allLanguages
        .where(
          (lang) =>
              lang.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.language,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    height: 48.h,
                    decoration: _searchDecoration,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: _searchTextStyle,
                      decoration: InputDecoration(
                        hintText: l10n.searchLanguage,
                        hintStyle: _searchHintStyle,
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            width: 24.w,
                            height: 24.w,
                            colorFilter: _searchIconColorFilter,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(l10n.languageChoice, style: _sectionHeadingStyle),
                  SizedBox(height: 16.h),
                  // Language list — each item is a StatelessWidget for identity
                  // tracking; only the selected item rebuilds on selection change.
                  ..._filteredLanguages.map(
                    (language) => _LanguageItem(
                      language: language,
                      isSelected: _selectedLanguage == language.name,
                      onTap: () =>
                          setState(() => _selectedLanguage = language.name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language list item ────────────────────────────────────────────────────────
// Extracted from _buildLanguageItem so Flutter can track each row's identity.
class _LanguageItem extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageItem({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  // static const Map — no new object created per getFlagEmoji call.
  static const _flagMap = {
    'en': '🇺🇸',
    'id': '🇮🇩',
    'ms': '🇲🇾',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
  };
  static String _getFlagEmoji(String code) => _flagMap[code] ?? '🏳️';

  static final _itemDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12.w)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1.w),
    ),
  );
  static final _inkRadius = BorderRadius.all(Radius.circular(12.w));
  static const _flagBgDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColor.kDividerGrey,
  );
  static final _emojiStyle = TextStyle(fontSize: 16.sp);
  static final _languageNameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: _itemDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: _inkRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: _flagBgDecoration,
                  child: Center(
                    child: Text(
                      _getFlagEmoji(language.code),
                      style: _emojiStyle,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(language.name, style: _languageNameStyle),
                ),
                SizedBox(width: 12.w),
                CommonRadioButton(isSelected: isSelected, size: 20.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
