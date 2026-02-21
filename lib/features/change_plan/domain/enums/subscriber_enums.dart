enum ModemStatus { online, offline }

enum SubscriberType { retail, corporate }

enum PlanTab { all, ottPlans }

enum SubscriberSearchType { subscriberId, username, mobile, email }

extension SubscriberSearchTypeExtension on SubscriberSearchType {
  String get title {
    switch (this) {
      case SubscriberSearchType.subscriberId:
        return "Subscriber ID";
      case SubscriberSearchType.username:
        return "Username";
      case SubscriberSearchType.mobile:
        return "Mobile No";
      case SubscriberSearchType.email:
        return "Email";
    }
  }
}

enum SubscriberConnectionType {
  // Retail connection types
  home,
  sme,
  ews,
  // Corporate connection types
  enterprise,
  government,
  governmentEo,
}

extension SubscriberConnectionTypeExtension on SubscriberConnectionType {
  String get title {
    switch (this) {
      case SubscriberConnectionType.home:
        return "Home Connection";
      case SubscriberConnectionType.sme:
        return "SME Connection";
      case SubscriberConnectionType.ews:
        return "EWS Connection";
      case SubscriberConnectionType.enterprise:
        return "Enterprise Connection";
      case SubscriberConnectionType.government:
        return "Government Connection";
      case SubscriberConnectionType.governmentEo:
        return "Government-Eo Connection";
    }
  }

  // Returns the segment this connection type belongs to
  SubscriberType get segment {
    switch (this) {
      case SubscriberConnectionType.home:
      case SubscriberConnectionType.sme:
      case SubscriberConnectionType.ews:
        return SubscriberType.retail;
      case SubscriberConnectionType.enterprise:
      case SubscriberConnectionType.government:
      case SubscriberConnectionType.governmentEo:
        return SubscriberType.corporate;
    }
  }
}
