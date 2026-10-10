/// Query parameter values for [SubscribersRepository.getSeasonalPackages].
abstract final class SeasonalPlanApiFilters {
  SeasonalPlanApiFilters._();

  static const subscriptionHome = 'home';
  static const subscriptionSme = 'sme';
  static const subscriptionEws = 'ews';

  static const packageFup = 'fup';
  static const packageUnlimited = 'unlimited';
}
