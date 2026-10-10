import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/util/app_locale.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/shared/widgets/common_radio_button.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_text_field.dart';

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

  /// Language code ('en' / 'hi') currently applied to the app.
  String? _selectedCode;
  String _searchQuery = '';

  // Only the languages the app ships translations for (see AppLocale.supported).
  // Each language is shown in its own script, with the English name for search.
  final List<Language> _allLanguages = [
    Language(name: 'English', flagAsset: '', code: 'en'),
    Language(name: 'हिन्दी (Hindi)', flagAsset: '', code: 'hi'),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start from the language the app is actually showing right now, which is
    // the saved choice or, when none was saved, the device language.
    _selectedCode ??= Localizations.localeOf(context).languageCode;
  }

  Future<void> _selectLanguage(Language language) async {
    if (_selectedCode == language.code) return;
    setState(() => _selectedCode = language.code);
    await AppLocale.set(Locale(language.code));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = context.bssSubL10n;
    return CommonTextField(
      hintText: l10n.searchLanguage,
      textEditingController: _searchController,
      onTextChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      borderRadius: 12.w,
      borderColor: const Color(0xFFF3F3FA),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      textStyle: TextStyle(
        fontFamily: 'General Sans',
        color: const Color(0xFF0F1121),
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.6.h,
        letterSpacing: 0,
      ),
      hintStyle: TextStyle(
        fontFamily: 'General Sans',
        color: const Color(0xFF67697A),
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.6.h,
        letterSpacing: 0,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.all(12.w),
        child: SvgPicture.asset(
          'assets/icons/search.svg',
          width: 24.w,
          height: 24.h,
          colorFilter: const ColorFilter.mode(
            Color(0xFF67697A),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Language language) {
    final isSelected = _selectedCode == language.code;

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
          onTap: () => _selectLanguage(language),
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                // Flag placeholder - replace with actual flag asset when available
                Container(
                  width: 24.w,
                  height: 24.h,
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
                      fontFamily: 'General Sans',
                      color: const Color(0xFF0F1121),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3.h,
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
    final flagMap = {'en': '🇬🇧', 'hi': '🇮🇳'};
    return flagMap[code] ?? '🏳️';
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
                  _buildSearchBar(context),
                  SizedBox(height: 20.h),
                  // Language Choice section
                  Text(
                    l10n.languageChoice,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: const Color(0xFF0F1121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3.h,
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

