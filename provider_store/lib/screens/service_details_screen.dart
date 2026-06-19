import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:provider_store/components/service/details/service_details_header.dart';
import 'package:provider_store/components/service/details/service_info_section.dart';
import 'package:provider_store/components/service/details/service_pricing_section.dart';
import 'package:provider_store/components/service/details/service_requirements_section.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ProvidedService initialService;
  final Future<ProvidedService>? detailedServiceFuture;
  const ServiceDetailsScreen({
    super.key,
    required this.initialService,
    this.detailedServiceFuture,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late ProvidedService _service;

  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _service = widget.initialService;

    // If we have a future for detailed service, load it
    if (widget.detailedServiceFuture != null) {
      _loadDetailedService();
    }
  }

  Future<void> _loadDetailedService() async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final detailedService = await widget.detailedServiceFuture!;
      setState(() {
        _service = detailedService;
      });
    } catch (e) {
      print('Error loading detailed service: $e');
      // Keep showing the initial service
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              ServiceDetailsHeader(
                service: _service,
                onBackPressed: () => Navigator.pop(context),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      ServiceInfoSection(service: _service),
                      const SizedBox(height: 24),
                      ServicePricingSection(service: _service),
                      const SizedBox(height: 24),
                      ServiceRequirementsSection(service: _service),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoadingDetails)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleEditService() {
    // TODO: Navigate to edit screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Service'),
        content: const Text('Edit functionality will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
