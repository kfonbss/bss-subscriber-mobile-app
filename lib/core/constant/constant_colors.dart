import 'dart:ui';

import 'package:kfon_subscriber/core/constant/app_brand.dart';

class AppColor {
  // =================
  static Color get kPrimaryColor => primaryFor(AppBrand.isLd ? 'LD' : null);

  /// Primary colour for a given tenant code, without switching the app's
  /// current tenant (used to preview the colour on the tenant screen).
  static Color primaryFor(String? tenantId) =>
      AppBrand.isLdTenant(tenantId)
          ? const Color(0xFF009DE2)
          : const Color(0xFF8D0247);

  /// Tenant screen background before any tenant is chosen.
  static const Color kTenantScreenBackground = Color(0xFF2D3142);

  // Opacity versions of kPrimaryColor (follow the tenant automatically)

  static Color get kPrimaryTint => kPrimaryColor.withAlpha(0x0C); // ~5%
  static Color get kPrimary5 => kPrimaryColor.withAlpha(0x0D); // 5%
  static Color get kPrimary10 => kPrimaryColor.withAlpha(0x1A); // 10%
  static Color get kPrimary15 => kPrimaryColor.withAlpha(0x26); // 15%
  static Color get kPrimary12 => kPrimaryColor.withAlpha(0x1F); // 12%

  // ================= Common colors (all tenants) =================
  static const Color kSecondaryColor = Color(0xFFF97316);
  static const Color kClearAllColor = Color(0xFFF97316);
  static const Color kTabActiveBackground = Color(0xFFFDE933);
  static const Color kCheckBoxColor = Color(0xFFFA872D);

  static Color get kIconBackground => kPrimaryColor.withAlpha(0x1A);
  static const Color kMainBackgroundColor = Color(0xFFF2EFE7);
  static const Color kTextFiledPlaceholderColor = Color(0xFF67697A);
  static const Color kAutopayButtonColor = Color(0xFFFDE832);
  static const Color kTextPrimary = Color(0xFF333333);
  static const Color kTextPrimary80 = Color(0xCC333333); // #333333 @ 80%
  static const Color kTextSecondaryLight = Color(0xFFB9BAC0);
  static const Color kCardShadow = Color(0x0F000000);
  static const Color kTextFiledLabelColor = Color(0xFF4C4C4C);
  static const Color kTextFiledHintColor = Color(0xFFA3A3A3);
  static const Color kTextFiledBorderColor = Color(0xFFA2A2A2);
  static const Color kYellowBackground = Color(0xFFFFFAEB);
  static const Color kProgressBarBackground = Color(0xFFD2B9C5);
  static const Color kBlackHeadingColor = Color(0xFF272727);
  static const Color kRadioButtonTextColor = Color(0xFF4C4C4C);
  static const Color kTransparentColor = Color.fromRGBO(255, 255, 255, 0.19);
  static const Color shimmerHighlightColor = Color(0xFFF4F4F4);
  static const Color kPendingOrange = Color(0xFFF97316);
  static const Color kCompletedGreen = Color(0xFF1B993C);
  static const Color kFailedRed = Color(0xFFB72727);
  static const Color kSecondaryBackgroundColor = Color(0xFFF5F5F5);
  static const Color kTextSecondary = Color(0xFF717171);
  static const Color kLabelGrey = Color(0xFF707070);
  static const Color kTextSecondaryDark = Color(0xFF0F1121);
  static const Color kDragHandleGrey = Color(0xFFB9BAC0);
  static const Color kSuspendedStatusText = Color(0xFFEA181B);
  static const Color kTabBarUnselectedText = Color(0xFF656070);
  static const Color kinputFiledLightBorder = Color(0xFFEAEAEA);
  static const Color kSlateGrey = Color(0xFF67697A);
  static const Color kDarkBlue = Color(0xFF354259);
  static const Color kIconContainerGrey = Color(0xFFF3F3FA);
  static const Color kNearBlack = Color(0xFF262629);
  static const Color kRichBlack = Color(0xFF1A1A1A);
  static const Color kTicketOpenBlue = Color(0xFF01889F);
  static const Color kTicketProgressOrange = Color(0xFFFA872D);
  static const Color kTicketClosedGreen = Color(0xFF1C8E52);
  static const Color kDividerGrey = Color(0xFFE1E1E4);
  static const Color kUrgentRed = Color(0xFFE53935);
  static const Color kMediumGrey = Color(0xFFA5A5A5);
  static const Color kWarmBackground = Color(0xFFEFEBE5);
  static const Color kSuccessGreen = Color(0xFF388E3C);
  static const Color kShimmerBase = Color(0xFFE0E0E0);
  static const Color kBorderLightGrey = Color(0xFFD9D9D9);
  static const Color kDarkCharcoal = Color(0xFF333333);
  static const Color kNavyBlue = Color(0xFF232F50);
  static const Color kCharcoalDark = Color(0xFF1F2024);
  static const Color kStatusPendingOrange = Color(0xFFE8820C);
  static const Color kStatusSuccessText = Color(0xFF4CAF50);
  static const Color kStatusFailRed = Color(0xFFD0214A);
  static const Color kStatusPendingBg = Color(0xFFFFF0E0);
  static const Color kStatusSuccessBg = Color(0xFFE8F5E9);
  static const Color kStatusFailBg = Color(0xFFFCE8EC);
  static const Color kDisabledGrey = Color(0xFFCCCCCC);
  static const Color kMutedIconGrey = Color(0xFF767681);
  static const Color kBodyTextGrey = Color(0xFF636363);
  static const Color kPriorityHigh = Color(0xFFFB8C00);
  static const Color kPriorityMedium = Color(0xFFE9BE00);
  static const Color kPriorityLow = Color(0xFF43A047);
  static const Color kToggleDisabledGrey = Color(0xFFE5E5E5);
  static const Color kDaysLeftYellow = Color(0xFFFDE933);
  static const Color kAvatarSandBg = Color(0xFFF3E2C8);
  static const Color kAvatarGoldText = Color(0xFFC2A060);
  static const Color kCardShadowDark = Color(0x0C000000);
  static const Color kTicketDetailIconBg = Color(0xFFFFF0F6);
  static const Color kBottomSheetTitle = Color(0xFF262629);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kWhite20 = Color(0x33FFFFFF); // white @ 20% opacity
  static const Color kWhite80 = Color(0xCCFFFFFF); // white @ 80% opacity

  // Intro screens (shown before a tenant is chosen)
  // The tenant is chosen before the intro, so these follow the tenant primary.
  static Color get kIntroBackground => kPrimaryColor;
  // Lighter tint of the primary (LD: #009DE2 → ≈ #26ACE6, close to the
  // original #27BDFF accent).
  static Color get kIntroAccent =>
      Color.lerp(kPrimaryColor, const Color(0xFFFFFFFF), 0.15)!;
  static const Color kWhite30 = Color(0x4DFFFFFF); // white @ 30% opacity
  static const Color kBlack4 = Color(0x0A000000); // black @ 4% opacity
  static const Color kBlack5 = Color(0x0D000000); // black @ 5% opacity
  static const Color kBlack8 = Color(0x14000000); // black @ 8% opacity
  static const Color kBlack10 = Color(0x1A000000); // black @ 10% opacity
  static const Color kBlack15 = Color(0x26000000); // black @ 15% opacity
  static const Color kBlack9 = Color(0x16000000); // black @ 9% opacity

  // Home quick actions
  static const Color kQuickRecharge = Color(0xFF14B8A6);
  static const Color kQuickTransactions = Color(0xFFF97316);
  static const Color kQuickInvoice = Color(0xFFEF4949);

  static const Color kHeadingDark = Color(0xFF121212);

  // Active package page
  static const Color kSpeedBoxGrey = Color(0xFFF2F2F2);
  static const Color kUsageTrackGrey = Color(0xFFE2E2E2);
  static const Color kActiveGreen = Color(0xFF27B73E);
  static const Color kActiveGreen10 = Color(0x1927B73E); // #27B73E @ 10%
  static const Color kServiceTitle = Color(0xFF141414);
  static const Color kBlack12 = Color(0x1F000000); // black @ 12% opacity
  static const Color kBlack20 = Color(0x33000000); // black @ 20% opacity
  static const Color kBlack50 = Color(0x80000000); // black @ 50% opacity
  static const Color kBlack70 = Color(0xB3000000); // black @ 70% opacity
  static const Color kBlack80 = Color(0xCC000000); // black @ 80% opacity
  static const Color kGrey15 = Color(0x26808080); // grey @ 15% opacity
  static const Color kCompletedGreen10 = Color(
    0x1A1B993C,
  ); // kCompletedGreen @ 10% opacity
  static const Color kDeepTeal10 = Color(0x1A005F73); // deep teal @ 10% opacity
  static const Color kErrorRed = Color(0xFFBA1A1A);
  static const Color kAttachmentErrorRed = Color(0xFFE23224);
  static const Color kCoralRed = Color(0xFFEF4949);
  static const Color kBrightRed = Color(0xFFE84040);
  static const Color kCrimsonRed = Color(0xFFD93025);
  static const Color kIconDark = Color(0xFF292D32);
  static const Color kDialogTitleDark = Color(0xFF2F3447);
  static const Color kNavyBlueDeep = Color(0xFF232F4F);
  static const Color kDarkGrey = Color(0xFF555555);
  static const Color kSearchIconGrey = Color(0xFF606169);
  static const Color kStoneGrey = Color(0xFF71727A);
  static const Color kHintGrey = Color(0xFF888888);
  static const Color kMutedGrey = Color(0xFF999999);
  static const Color kCoolGrey = Color(0xFF9CA3AF);
  static const Color kSilverGrey = Color(0xFFAAAAAA);
  static const Color kBorderGrey = Color(0xFFCBCBCB);
  static const Color kLightBorderGrey = Color(0xFFEEEEEE);
  static const Color kFieldBorder = Color(0xFFEDF1F3);
  static const Color kOffWhite = Color(0xFFF7F7F7);
  static const Color kProfileActiveGreen = Color(0xFF219653);
  static const Color kLogoutRed = Color(0xFFFF3939);
  static const Color kLogoutIconBg = Color(0xFFFFF7F7);
  static const Color kGhostWhite = Color(0xFFF8F9FE);
  static const Color kAliceBlueBg = Color(0xFFF2F7FF);
  static const Color kLightBlueBg = Color(0xFFE3F2FD);
  static const Color kLightSkyBlue = Color(0xFFB3DAFF);
  static const Color kMaterialBlue = Color(0xFF2196F3);
  static const Color kTeal = Color(0xFF00A896);
  static const Color kTealAccent = Color(0xFF14B8A6);
  static const Color kEmeraldGreen = Color(0xFF10B981);
  static const Color kDeepEmerald = Color(0xFF047857);
  static const Color kJungleGreen = Color(0xFF008F67);
  static const Color kForestGreen = Color(0xFF1E8E3E);
  static const Color kMintGreenBg = Color(0xFFE6F4EA);
  static const Color kBrightYellow = Color(0xFFFFD600);
  static const Color kGoldYellow = Color(0xFFFFD000);
  static const Color kLightAmber = Color(0xFFFFD54F);
  static const Color kCreamYellowBg = Color(0xFFFFF9E6);
  static const Color kPeachBg = Color(0xFFFFF8EE);
  static const Color kPeachBorder = Color(0xFFF3C892);
  static const Color kDarkOrange = Color(0xFFFF8C00);
  static const Color kBrightOrange = Color(0xFFFF6B2C);
  static const Color kBurntOrange = Color(0xFFE8671A);
  static const Color kAmberDark = Color(0xFFB45309);
  static const Color kAmberBrown = Color(0xFF92400E);
  static const Color kDarkGoldenrod = Color(0xFFAF7700);
  static const Color kSienna = Color(0xFFA0522D);
  static const Color kPurple = Color(0xFF6A4FA3);
  static const Color kLavenderBlushBg = Color(0xFFF9F2F6);
  static const Color kPinkMistBg = Color(0xFFF4E6ED);

  // Recharge page
  static const Color kCardBorderBeige = Color(0xFFEAE6DE);
  static const Color kDividerLight = Color(0xFFF3F4F6);
  static const Color kTotalDivider = Color(0xFFDADADA);
  static const Color kSlate900 = Color(0xFF0F172A);
  static const Color kSlate800 = Color(0xFF1E293B);
  static const Color kSlate700 = Color(0xFF334155);
  static const Color kSlate600 = Color(0xFF475569);
  static const Color kSlate500 = Color(0xFF64748B);
  static const Color kSlate300 = Color(0xFFCBD5E1);
  static const Color kSlate100 = Color(0xFFF1F5F9);
  static const Color kSlate900Alpha35 = Color(
    0x590F172A,
  ); // kSlate900 @ 35% opacity
  static const Color kTagGreyText = Color(0xFF7B7B7B);
  static const Color kSectionLabelGrey = Color(0xFF7A7A7A);
  static const Color kDiscountGreen = Color(0xFF059669);
  static const Color kDiscountGreenBg = Color(0xFFECFDF5);
  static const Color kDiscountGreenBorder = Color(0xFFA7F3D0);
  static const Color kSufficientBorder = Color(0xFFD1FAE5);
  static const Color kSecureNoteText = Color(0xFF065F46);
  static const Color kSecureNoteBg = Color(
    0xE5ECFDF5,
  ); // kDiscountGreenBg @ 90% opacity
  static const Color kSecureNoteBorder = Color(
    0xCCA7F3D0,
  ); // kDiscountGreenBorder @ 80% opacity
  static const Color kSecureIconBg = Color(
    0x1910B981,
  ); // kEmeraldGreen @ 10% opacity
  static const Color kBlack2 = Color(0x05000000); // black @ 2% opacity
  static const Color kBlack3 = Color(0x07000000); // black @ 3% opacity

  // Auto Pay
  static const Color kStone900 = Color(0xFF1C1917);
  static const Color kStone800 = Color(0xFF292524);
  static const Color kStone700 = Color(0xFF44403C);
  static const Color kStone600 = Color(0xFF57534E);
  static const Color kStone600Alpha80 = Color(
    0xCC57534E,
  ); // kStone600 @ 80% opacity
  static const Color kStone500 = Color(0xFF78716C);
  static const Color kStone400 = Color(0xFFA8A29E);
  static const Color kStone300 = Color(0xFFD6D3D1);
  static const Color kStone200 = Color(0xFFE7E5E4);
  static const Color kStone200Alpha70 = Color(
    0xB2E7E5E4,
  ); // kStone200 @ 70% opacity
  static const Color kStone100 = Color(0xFFF5F5F4);
  static const Color kInfoBannerBorder = Color(0xFFE1E1E1);
  static const Color kNeutralBgAlpha70 = Color(
    0xB2F5F5F5,
  ); // #F5F5F5 @ 70% opacity
  static const Color kGrey200 = Color(0xFFE5E7EB);
  static const Color kPlanCardGradientStart = Color(0xFFFEF6E0);
  static const Color kPlanCardGradientEnd = Color(0xFFFDE9EE);
  static const Color kPlanCardBorder = Color(
    0x266B1733,
  ); // #6B1733 @ 15% opacity
  static const Color kPlanCardDivider = Color(0xFFE7CCCF);
  static const Color kCardShadowWine = Color(
    0x0C73163E,
  ); // #73163E @ 5% opacity
  static const Color kRemoveButtonBg = Color(
    0x66FFF1F2,
  ); // #FFF1F2 @ 40% opacity
  static const Color kRemoveButtonBorder = Color(0xFFFECDD3);
  static const Color kRemoveButtonText = Color(0xFFBE123C);
  static const Color kRemoveIconBg = Color(0xFFFFDAD6);
  static const Color kSheetTitle = Color(0xFF2D2D2D);
  static const Color kSheetMessage = Color(0xFF5B5B5B);
}
