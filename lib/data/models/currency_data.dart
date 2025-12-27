/// A model class representing detailed information about a currency.
///
/// This includes its ISO code, English and Arabic names, and its symbol.
class CurrencyInfo {
  /// The ISO 4217 currency code (e.g., 'USD', 'SDG').
  final String code;
  /// The name of the currency in English (e.g., 'Sudanese Pound').
  final String nameEn;
  /// The name of the currency in Arabic (e.g., 'الجنيه السوداني').
  final String nameAr;
  /// The symbol used for the currency (e.g., '\$', 'ج.س').
  final String symbol;

  /// Creates a [CurrencyInfo] instance with the given details.
  const CurrencyInfo({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.symbol,
  });
}

/// The default currency code used across the application.
const String defaultCurrency = 'SDG';

/// A comprehensive list of [CurrencyInfo] objects representing all supported currencies.
///
/// This list primarily includes currencies from Islamic countries, along with major world currencies.
const List<CurrencyInfo> supportedCurrencies = [
  // === Middle East ===
  CurrencyInfo(code: 'SDG', nameEn: 'Sudanese Pound', nameAr: 'الجنيه السوداني', symbol: 'ج.س'),
  CurrencyInfo(code: 'SAR', nameEn: 'Saudi Riyal', nameAr: 'الريال السعودي', symbol: '﷼'),
  CurrencyInfo(code: 'AED', nameEn: 'UAE Dirham', nameAr: 'الدرهم الإماراتي', symbol: 'د.إ'),
  CurrencyInfo(code: 'QAR', nameEn: 'Qatari Riyal', nameAr: 'الريال القطري', symbol: '﷼'),
  CurrencyInfo(code: 'KWD', nameEn: 'Kuwaiti Dinar', nameAr: 'الدينار الكويتي', symbol: 'د.ك'),
  CurrencyInfo(code: 'BHD', nameEn: 'Bahraini Dinar', nameAr: 'الدينار البحريني', symbol: '.د.ب'),
  CurrencyInfo(code: 'OMR', nameEn: 'Omani Rial', nameAr: 'الريال العماني', symbol: '﷼'),
  CurrencyInfo(code: 'JOD', nameEn: 'Jordanian Dinar', nameAr: 'الدينار الأردني', symbol: 'د.ا'),
  CurrencyInfo(code: 'IQD', nameEn: 'Iraqi Dinar', nameAr: 'الدينار العراقي', symbol: 'ع.د'),
  CurrencyInfo(code: 'SYP', nameEn: 'Syrian Pound', nameAr: 'الليرة السورية', symbol: '£S'),
  CurrencyInfo(code: 'LBP', nameEn: 'Lebanese Pound', nameAr: 'الليرة اللبنانية', symbol: 'ل.ل'),
  CurrencyInfo(code: 'YER', nameEn: 'Yemeni Rial', nameAr: 'الريال اليمني', symbol: '﷼'),
  
  // === North Africa ===
  CurrencyInfo(code: 'EGP', nameEn: 'Egyptian Pound', nameAr: 'الجنيه المصري', symbol: 'ج.م'),
  CurrencyInfo(code: 'LYD', nameEn: 'Libyan Dinar', nameAr: 'الدينار الليبي', symbol: 'ل.د'),
  CurrencyInfo(code: 'TND', nameEn: 'Tunisian Dinar', nameAr: 'الدينار التونسي', symbol: 'د.ت'),
  CurrencyInfo(code: 'DZD', nameEn: 'Algerian Dinar', nameAr: 'الدينار الجزائري', symbol: 'د.ج'),
  CurrencyInfo(code: 'MAD', nameEn: 'Moroccan Dirham', nameAr: 'الدرهم المغربي', symbol: 'د.م'),
  CurrencyInfo(code: 'MRU', nameEn: 'Mauritanian Ouguiya', nameAr: 'الأوقية الموريتانية', symbol: 'أ.م'),
  
  // === South/Central Asia ===
  CurrencyInfo(code: 'PKR', nameEn: 'Pakistani Rupee', nameAr: 'الروبية الباكستانية', symbol: '₨'),
  CurrencyInfo(code: 'BDT', nameEn: 'Bangladeshi Taka', nameAr: 'التاكا البنغلاديشية', symbol: '৳'),
  CurrencyInfo(code: 'AFN', nameEn: 'Afghan Afghani', nameAr: 'الأفغاني الأفغاني', symbol: '؋'),
  CurrencyInfo(code: 'IRR', nameEn: 'Iranian Rial', nameAr: 'الريال الإيراني', symbol: '﷼'),
  CurrencyInfo(code: 'TRY', nameEn: 'Turkish Lira', nameAr: 'الليرة التركية', symbol: '₺'),
  CurrencyInfo(code: 'AZN', nameEn: 'Azerbaijani Manat', nameAr: 'المانات الأذربيجاني', symbol: '₼'),
  CurrencyInfo(code: 'KZT', nameEn: 'Kazakhstani Tenge', nameAr: 'التنغي الكازاخستاني', symbol: '₸'),
  CurrencyInfo(code: 'UZS', nameEn: 'Uzbekistani Som', nameAr: 'السوم الأوزبكستاني', symbol: 'сўм'),
  CurrencyInfo(code: 'TMT', nameEn: 'Turkmenistani Manat', nameAr: 'المانات التركمانستاني', symbol: 'm'),
  CurrencyInfo(code: 'TJS', nameEn: 'Tajikistani Somoni', nameAr: 'السوموني الطاجيكستاني', symbol: 'ЅМ'),
  CurrencyInfo(code: 'KGS', nameEn: 'Kyrgyzstani Som', nameAr: 'السوم القيرغيزستاني', symbol: 'сом'),
  
  // === Southeast Asia ===
  CurrencyInfo(code: 'IDR', nameEn: 'Indonesian Rupiah', nameAr: 'الروبية الإندونيسية', symbol: 'Rp'),
  CurrencyInfo(code: 'MYR', nameEn: 'Malaysian Ringgit', nameAr: 'الرينغيت الماليزي', symbol: 'RM'),
  CurrencyInfo(code: 'BND', nameEn: 'Brunei Dollar', nameAr: 'دولار بروناي', symbol: 'B\$'),
  
  // === Africa ===
  CurrencyInfo(code: 'NGN', nameEn: 'Nigerian Naira', nameAr: 'النايرا النيجيرية', symbol: '₦'),
  CurrencyInfo(code: 'XOF', nameEn: 'West African CFA', nameAr: 'الفرنك الأفريقي', symbol: 'CFA'),
  CurrencyInfo(code: 'GHS', nameEn: 'Ghanaian Cedi', nameAr: 'السيدي الغاني', symbol: '₵'),
  CurrencyInfo(code: 'KES', nameEn: 'Kenyan Shilling', nameAr: 'الشلن الكيني', symbol: 'KSh'),
  CurrencyInfo(code: 'TZS', nameEn: 'Tanzanian Shilling', nameAr: 'الشلن التنزاني', symbol: 'TSh'),
  CurrencyInfo(code: 'UGX', nameEn: 'Ugandan Shilling', nameAr: 'الشلن الأوغندي', symbol: 'USh'),
  CurrencyInfo(code: 'ETB', nameEn: 'Ethiopian Birr', nameAr: 'البر الإثيوبي', symbol: 'Br'),
  CurrencyInfo(code: 'SOS', nameEn: 'Somali Shilling', nameAr: 'الشلن الصومالي', symbol: 'Sh'),
  CurrencyInfo(code: 'DJF', nameEn: 'Djiboutian Franc', nameAr: 'الفرنك الجيبوتي', symbol: 'Fdj'),
  CurrencyInfo(code: 'KMF', nameEn: 'Comorian Franc', nameAr: 'الفرنك القمري', symbol: 'CF'),
  
  // === Major World Currencies ===
  CurrencyInfo(code: 'USD', nameEn: 'US Dollar', nameAr: 'الدولار الأمريكي', symbol: '\$'),
  CurrencyInfo(code: 'EUR', nameEn: 'Euro', nameAr: 'اليورو', symbol: '€'),
  CurrencyInfo(code: 'GBP', nameEn: 'British Pound', nameAr: 'الجنيه الإسترليني', symbol: '£'),
  CurrencyInfo(code: 'CNY', nameEn: 'Chinese Yuan', nameAr: 'اليوان الصيني', symbol: '¥'),
  CurrencyInfo(code: 'INR', nameEn: 'Indian Rupee', nameAr: 'الروبية الهندية', symbol: '₹'),
];

/// Finds a [CurrencyInfo] object from the [supportedCurrencies] list based on its currency code.
///
/// - Parameters:
///   - `code`: The ISO 4217 currency code to search for.
/// - Returns: The [CurrencyInfo] object if found, otherwise `null`.
CurrencyInfo? findCurrencyByCode(String code) {
  try {
    return supportedCurrencies.firstWhere((c) => c.code == code);
  } catch (_) {
    return null;
  }
}
