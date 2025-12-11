import 'package:flutter/material.dart';
import '../models/countries.dart'; // Asegúrate de que este import sea correcto

class StartupFormProvider extends ChangeNotifier {
  final String userId;

  StartupFormProvider({required this.userId});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers principales
  // Nombre de la startup
  final TextEditingController startupNameController = TextEditingController();

  final TextEditingController foundedYearController = TextEditingController();
  final TextEditingController fundingAmountUsdController =
      TextEditingController();
  final TextEditingController employeeCountController = TextEditingController();
  final TextEditingController estimatedRevenueUsdController =
      TextEditingController();
  final TextEditingController estimatedValuationUsdController =
      TextEditingController();
  final TextEditingController coInvestorsCountController =
      TextEditingController();

  // Controllers para campos "Other"
  final TextEditingController otherCountryController = TextEditingController();
  final TextEditingController otherRegionController = TextEditingController();
  final TextEditingController otherIndustryController = TextEditingController();
  final TextEditingController otherFundingRoundController =
      TextEditingController();
  final TextEditingController otherLeadInvestorController =
      TextEditingController();

  // Selections
  String? country;
  String? region;
  String? industry;
  String? fundingRound;
  String? leadInvestor;
  DateTime? fundingDate;
  bool exited = false;

  // Tags
  final Map<String, bool> tags = {
    'tag_AI': false,
    'tag_B2B': false,
    'tag_B2C': false,
    'tag_Blockchain': false,
    'tag_Cloud': false,
    'tag_EdTech': false,
    'tag_HealthTech': false,
    'tag_IoT': false,
    'tag_Marketplace': false,
    'tag_Mobile': false,
    'tag_SaaS': false,
  };

  // Opciones
  final List<String> fundingRounds = [
    'Pre-Seed',
    'Seed',
    'Series A',
    'Series B',
    'Series C',
    'Series D',
    'Other',
  ];
  final List<String> leadInvestors = [
    'Andreessen Horowitz',
    'Index Ventures',
    'Sequoia',
    'SoftBank',
    'Tiger Global',
    'Y Combinator',
    'Other',
  ];
  final List<String> regions = [
    'Europe',
    'Latin America',
    'MENA',
    'North America',
    'Oceania',
    'Other',
  ];
  final List<String> industries = [
    'Blockchain',
    'E-commerce',
    'Fintech',
    'Healthcare',
    'Logistics',
    'SaaS',
    'Other',
  ];
  final List<String> countriesList = [...countries, 'Other'];

  // --- Widget helpers ---
  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (isNumber && double.tryParse(value) == null) { // Usar double para ser más flexible
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdown(
    String label,
    String? value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
        validator: (v) =>
            v == null || v.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget buildOtherField(
    String? selectionValue,
    TextEditingController controller,
    String label,
  ) {
    if (selectionValue == 'Other') return buildTextField(label, controller);
    return const SizedBox.shrink();
  }

  // --- Setters ---
  void setCountry(String? v) {
    country = v;
    if (v != 'Other') otherCountryController.clear();
    notifyListeners();
  }

  void setRegion(String? v) {
    region = v;
    if (v != 'Other') otherRegionController.clear();
    notifyListeners();
  }

  void setIndustry(String? v) {
    industry = v;
    if (v != 'Other') otherIndustryController.clear();
    notifyListeners();
  }

  void setFundingRound(String? v) {
    fundingRound = v;
    if (v != 'Other') otherFundingRoundController.clear();
    notifyListeners();
  }

  void setLeadInvestor(String? v) {
    leadInvestor = v;
    if (v != 'Other') otherLeadInvestorController.clear();
    notifyListeners();
  }

  void setExited(bool v) {
    exited = v;
    notifyListeners();
  }

  void setTag(String tagKey, bool value) {
    tags[tagKey] = value;
    notifyListeners();
  }

  // --- Date picker ---
  Future<void> pickFundingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fundingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      fundingDate = picked;
      notifyListeners();
    }
  }

  // --- Validation ---
  bool validateForm() {
    final form = formKey.currentState;
    if (form == null) return false;
    if (!form.validate()) return false;
    if (fundingDate == null) return false;
    return true;
  }

  // --- Build record ---
  Map<String, dynamic> buildRecord() {
    int? tryParseInt(String? s) =>
        (s == null || s.isEmpty) ? null : int.tryParse(s);
    double? tryParseDouble(String? s) =>
        (s == null || s.isEmpty) ? null : double.tryParse(s);
    final Map<String, dynamic> record = {};

    // Añadimos userId al record
    record['user_id'] = userId;

    // Nombre de la startup (para enlazar con la tabla start-up)
    record['start_up_name'] = startupNameController.text.trim();

    record['founded_year'] = tryParseInt(foundedYearController.text);
    record['funding_amount_usd'] = tryParseDouble(
      fundingAmountUsdController.text,
    );
    record['employee_count'] = tryParseInt(employeeCountController.text);
    record['estimated_revenue_usd'] = tryParseDouble(
      estimatedRevenueUsdController.text,
    );
    record['estimated_valuation_usd'] = tryParseDouble(
      estimatedValuationUsdController.text,
    );
    record['co_investors_count'] = tryParseInt(coInvestorsCountController.text);

    // El nuevo modelo usa la columna 'exited_True' (1 = la startup YA salió, 0 = no ha salido).
    record['exited_True'] = exited ? 1 : 0;

    if (fundingDate != null) {
      final d = fundingDate!;
      record['funding_date_day'] = d.day;
      record['funding_date_month'] = d.month;
      record['funding_date_year'] = d.year;
      record['funding_date_weekday'] = d.weekday;
      record['funding_date_quarter'] = ((d.month - 1) ~/ 3) + 1;
    }

    for (final k in tags.keys) {
      record[k] = (tags[k] ?? false) ? 1 : 0;
    }

    record.addAll(
      oneHotEncode(
        'country',
        country == 'Other' ? otherCountryController.text : country,
        countriesList,
      ),
    );
    record.addAll(
      oneHotEncode(
        'region',
        region == 'Other' ? otherRegionController.text : region,
        regions,
      ),
    );
    record.addAll(
      oneHotEncode(
        'industry',
        industry == 'Other' ? otherIndustryController.text : industry,
        industries,
      ),
    );
    record.addAll(
      oneHotEncode(
        'funding_round',
        fundingRound == 'Other'
            ? otherFundingRoundController.text
            : fundingRound,
        fundingRounds,
      ),
    );
    record.addAll(
      oneHotEncode(
        'lead_investor',
        leadInvestor == 'Other'
            ? otherLeadInvestorController.text
            : leadInvestor,
        leadInvestors,
      ),
    );

    return record;
  }

  // --- JSON listo para API ---
  // Construye el vector de features EXACTAMENTE en el orden que espera investment-pred.json.
  // feature_names del modelo:
  // [
  //   founded_year,
  //   funding_amount_usd,
  //   employee_count,
  //   estimated_revenue_usd,
  //   estimated_valuation_usd,
  //   funding_date_day,
  //   funding_date_month,
  //   funding_date_year,
  //   funding_date_weekday,
  //   funding_date_quarter,
  //   co_investors_count,
  //   region_Europe,
  //   region_Latin America,
  //   region_MENA,
  //   region_North America,
  //   region_Oceania,
  //   industry_Blockchain,
  //   industry_E-commerce,
  //   industry_Fintech,
  //   industry_Healthcare,
  //   industry_Logistics,
  //   industry_SaaS,
  //   funding_round_Pre-Seed,
  //   funding_round_Seed,
  //   funding_round_Series A,
  //   funding_round_Series B,
  //   funding_round_Series C,
  //   funding_round_Series D,
  //   exited_True,
  // ]
  Map<String, dynamic> buildJsonForApi() {
    final record = buildRecord();

    double _d(dynamic value) => (value ?? 0).toDouble();

    final List<double> features = [
      // 1-5: numéricos principales
      _d(record['founded_year']),
      (record['funding_amount_usd'] ?? 0.0) as double,
      _d(record['employee_count']),
      (record['estimated_revenue_usd'] ?? 0.0) as double,
      (record['estimated_valuation_usd'] ?? 0.0) as double,
      // 6-10: fecha
      _d(record['funding_date_day']),
      _d(record['funding_date_month']),
      _d(record['funding_date_year']),
      _d(record['funding_date_weekday']),
      _d(record['funding_date_quarter']),
      // 11: co_investors_count
      _d(record['co_investors_count']),
      // 12-16: regiones (one-hot)
      _d(record['region_Europe']),
      _d(record['region_Latin America']),
      _d(record['region_MENA']),
      _d(record['region_North America']),
      _d(record['region_Oceania']),
      // 17-22: industrias (one-hot)
      _d(record['industry_Blockchain']),
      _d(record['industry_E-commerce']),
      _d(record['industry_Fintech']),
      _d(record['industry_Healthcare']),
      _d(record['industry_Logistics']),
      _d(record['industry_SaaS']),
      // 23-28: funding_round (one-hot)
      _d(record['funding_round_Pre-Seed']),
      _d(record['funding_round_Seed']),
      _d(record['funding_round_Series A']),
      _d(record['funding_round_Series B']),
      _d(record['funding_round_Series C']),
      _d(record['funding_round_Series D']),
      // 29: exited_True
      _d(record['exited_True']),
    ];

    // La API de FastAPI espera 'user_id' (para logging/BD) y 'features' para el modelo.
    return {
      'user_id': userId,
      'features': features,
    };
  }

  Map<String, int> oneHotEncode(
    String prefix,
    String? value,
    List<String> options,
  ) {
    final Map<String, int> out = {};
    for (final opt in options) {
      out['${prefix}_$opt'] = (opt == value) ? 1 : 0;
    }
    return out;
  }

  void resetForm() {
    startupNameController.clear();
    foundedYearController.clear();
    fundingAmountUsdController.clear();
    employeeCountController.clear();
    estimatedRevenueUsdController.clear();
    estimatedValuationUsdController.clear();
    coInvestorsCountController.clear();
    otherCountryController.clear();
    otherRegionController.clear();
    otherIndustryController.clear();
    otherFundingRoundController.clear();
    otherLeadInvestorController.clear();
    country = null;
    region = null;
    industry = null;
    fundingRound = null;
    leadInvestor = null;
    fundingDate = null;
    exited = false;
    tags.updateAll((key, value) => false);
    notifyListeners();
  }

  @override
  void dispose() {
    startupNameController.dispose();
    foundedYearController.dispose();
    fundingAmountUsdController.dispose();
    employeeCountController.dispose();
    estimatedRevenueUsdController.dispose();
    estimatedValuationUsdController.dispose();
    coInvestorsCountController.dispose();
    otherCountryController.dispose();
    otherRegionController.dispose();
    otherIndustryController.dispose();
    otherFundingRoundController.dispose();
    otherLeadInvestorController.dispose();
    super.dispose();
  }
}