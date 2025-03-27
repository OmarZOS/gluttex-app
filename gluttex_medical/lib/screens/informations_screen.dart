import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [
                              const Color.fromARGB(255, 100, 110, 105),
                              const Color(0xFF186A3B)
                            ] // Darker green shades
                          : [
                              const Color(0xFF2ECC71),
                              const Color.fromARGB(255, 143, 197, 166)
                            ], // Your main color + slightly darker
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      package: "gluttex_medical",
                      height: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              pinned: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.aboutAppTab),
                  Tab(text: AppLocalizations.of(context)!.illnessInfoTab),
                ],
                indicatorColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAppInfoTab(context),
            _buildIllnessInfoTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(AppLocalizations.of(context)!.appPurposeTitle),
          _buildSectionText(AppLocalizations.of(context)!.appPurposeContent),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.featuresTitle),
          _buildFeatureTile(
              Icons.store, AppLocalizations.of(context)!.feature1),
          _buildFeatureTile(
              Icons.gamepad, AppLocalizations.of(context)!.feature2),
          _buildFeatureTile(
              Icons.menu_book_outlined, AppLocalizations.of(context)!.feature3),
          _buildFeatureTile(
              Icons.location_on, AppLocalizations.of(context)!.feature4),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.contactUsTitle),
          _buildContactOption(
              Icons.email, AppLocalizations.of(context)!.contactEmail),
          _buildContactOption(
              Icons.phone, AppLocalizations.of(context)!.contactPhone),
        ],
      ),
    );
  }

  Widget _buildIllnessInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              AppLocalizations.of(context)!.illnessOverviewTitle),
          _buildSectionText(
              AppLocalizations.of(context)!.illnessOverviewContent),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.symptomsTitle),
          _buildSymptomItem(AppLocalizations.of(context)!.symptom1),
          _buildSymptomItem(AppLocalizations.of(context)!.symptom2),
          _buildSymptomItem(AppLocalizations.of(context)!.symptom3),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.treatmentTitle),
          _buildSectionText(AppLocalizations.of(context)!.treatmentContent),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.resourcesTitle),
          _buildResourceLink(AppLocalizations.of(context)!.resource1),
          _buildResourceLink(AppLocalizations.of(context)!.resource2),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Handle link opening
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
