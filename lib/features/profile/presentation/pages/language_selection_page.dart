import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/presentation/components/common_radio_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class Language {
  final String name;
  final String flagAsset; // Placeholder for flag asset path
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

  List<Language> get _filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _allLanguages;
    }
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFF3F3FA), width: 1.w),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          fontFamily: 'GeneralSans',
          color: const Color(0xFF0F1121),
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText:'Search language',
          hintStyle: TextStyle(
            fontFamily: 'GeneralSans',
            color: const Color(0xFF67697A),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 1.6,
            letterSpacing: 0,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 24.w,
              height: 24.w,
              colorFilter: const ColorFilter.mode(
                Color(0xFF67697A),
                BlendMode.srcIn,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Language language) {
    final isSelected = _selectedLanguage == language.name;

    return Container(
      height: 56.h,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLanguage = language.name;
            });
            // TODO: Save language preference
          },
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                // Flag placeholder - replace with actual flag asset when available
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      _getFlagEmoji(language.code),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    language.name,
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      color: const Color(0xFF0F1121),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Radio button
                CommonRadioButton(isSelected: isSelected, size: 20.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFlagEmoji(String code) {
    // Simple emoji flags as placeholders
    final flagMap = {
      'en': '🇺🇸',
      'id': '🇮🇩',
      'ms': '🇲🇾',
      'ja': '🇯🇵',
      'zh': '🇨🇳',
    };
    return flagMap[code] ?? '🏳️';
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: 'Language',
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
                  _buildSearchBar(context),
                  SizedBox(height: 20.h),
                  // Language Choice section
                  Text(
                    'Language Choice',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      color: const Color(0xFF0F1121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Language list
                  ..._filteredLanguages.map(
                    (language) => _buildLanguageItem(language),
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
