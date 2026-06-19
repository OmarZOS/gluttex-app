import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StunningFeeSection extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? initialFeeData;
  final ValueChanged<Map<String, dynamic>> onFeeChanged;

  const StunningFeeSection({
    Key? key,
    this.isEditing = false,
    this.initialFeeData,
    required this.onFeeChanged,
  }) : super(key: key);

  @override
  _StunningFeeSectionState createState() => _StunningFeeSectionState();
}

class _StunningFeeSectionState extends State<StunningFeeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _cardColorAnimation;

  // Fee Fields
  int _additionalFeeId = 0;
  int _additionalFeePaymentId = 0;
  String _additionalFeeName = '';
  double _additionalFeeAmount = 0.0;
  String _additionalFeeDescription = '';
  String _additionalFeeDocumentUrl = '';
  int _additionalFeeUserId = 0;
  int _additionalFeeOnProviderId = 0;

  bool _isExpanded = true;
  bool _isLoading = false;
  bool _showDocumentField = false;

  final List<Color> _gradientColors = [
    const Color(0xFF667EEA),
    const Color(0xFF764BA2),
    const Color(0xFFF093FB),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _cardColorAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.9),
      end: Colors.white,
    ).animate(_animationController);

    _loadInitialData();

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _loadInitialData() {
    if (widget.isEditing && widget.initialFeeData != null) {
      final fee = widget.initialFeeData!;
      _additionalFeeId = fee['additional_fee_id'] ?? 0;
      _additionalFeePaymentId = fee['additional_fee_payment_id'] ?? 0;
      _additionalFeeName = fee['additional_fee_name'] ?? '';
      _additionalFeeAmount = (fee['additional_fee_amount'] ?? 0).toDouble();
      _additionalFeeDescription = fee['additional_fee_description'] ?? '';
      _additionalFeeDocumentUrl = fee['additional_fee_document_url'] ?? '';
      _additionalFeeUserId = fee['additional_fee_user_id'] ?? 0;
      _additionalFeeOnProviderId = fee['additional_fee_on_provider_id'] ?? 0;

      if (_additionalFeeDocumentUrl.isNotEmpty) {
        _showDocumentField = true;
      }
    }
  }

  void _notifyChanges() {
    widget.onFeeChanged({
      'additional_fee_id': _additionalFeeId,
      'additional_fee_payment_id': _additionalFeePaymentId,
      'additional_fee_name': _additionalFeeName,
      'additional_fee_amount': _additionalFeeAmount,
      'additional_fee_description': _additionalFeeDescription,
      'additional_fee_document_url': _additionalFeeDocumentUrl,
      'additional_fee_user_id': _additionalFeeUserId,
      'additional_fee_on_provider_id': _additionalFeeOnProviderId,
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.2),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradientColors
                      .map((color) => color.withOpacity(0.05))
                      .toList(),
                ),
              ),
              child: Material(
                color: _cardColorAnimation.value,
                borderRadius: BorderRadius.circular(24),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header with animated icon
                      _buildSectionHeader(),

                      const SizedBox(height: 24),

                      if (_isExpanded) _buildExpandedContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _gradientColors.first.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.125 : 0,
                    child: const Icon(
                      Icons.attach_money_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Fees',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add extra charges & fees',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isExpanded ? 0.5 : 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.expand_more_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        // Fee ID Badge (if editing)
        if (widget.isEditing && _additionalFeeId > 0) _buildFeeIdBadge(),

        const SizedBox(height: 24),

        // Fee Name with floating label
        _buildFloatingLabelField(
          label: 'Fee Name',
          icon: Icons.title_rounded,
          initialValue: _additionalFeeName,
          onChanged: (value) {
            setState(() => _additionalFeeName = value);
            _notifyChanges();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a fee name';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildAmountCard(
                label: 'Fee Amount',
                value: _additionalFeeAmount,
                onChanged: (value) {
                  setState(() => _additionalFeeAmount = value);
                  _notifyChanges();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPaymentIdField(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Fee Description with character counter
        _buildDescriptionField(),

        const SizedBox(height: 20),

        // Document URL Toggle
        _buildDocumentToggle(),

        if (_showDocumentField)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildDocumentField(),
          ),

        const SizedBox(height: 20),

        // User and Provider IDs
        _buildIdCards(),

        const SizedBox(height: 24),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildFeeIdBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gradientColors[1].withOpacity(0.1),
            _gradientColors[2].withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _gradientColors[1].withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _gradientColors[1].withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 16,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Fee ID: $_additionalFeeId',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _gradientColors[1],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabelField({
    required String label,
    required IconData icon,
    required String initialValue,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          floatingLabelStyle: MaterialStateTextStyle.resolveWith(
            (states) {
              final color = states.contains(MaterialState.focused)
                  ? _gradientColors[1]
                  : Colors.grey;
              return TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              );
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _gradientColors[1],
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _gradientColors[0].withOpacity(0.05),
            _gradientColors[1].withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _gradientColors[0].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: _gradientColors[0],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'DZD',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _gradientColors[1],
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: value == 0 ? '' : value.toStringAsFixed(2),
                    onChanged: (text) {
                      final amount = double.tryParse(text) ?? 0.0;
                      onChanged(amount);
                      _notifyChanges();
                    },
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _gradientColors[1],
                        ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIdField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment ID',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _additionalFeePaymentId == 0
                  ? ''
                  : _additionalFeePaymentId.toString(),
              onChanged: (text) {
                final id = int.tryParse(text) ?? 0;
                setState(() => _additionalFeePaymentId = id);
                _notifyChanges();
              },
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter ID',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: const Icon(
                    FontAwesomeIcons.hashtag,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _gradientColors[2].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_rounded,
                color: _gradientColors[2],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Description',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Text(
              '${_additionalFeeDescription.length}/200',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _additionalFeeDescription.length > 200
                        ? Colors.red
                        : Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            color: Colors.white,
          ),
          child: TextFormField(
            initialValue: _additionalFeeDescription,
            onChanged: (value) {
              setState(() => _additionalFeeDescription = value);
              _notifyChanges();
            },
            maxLines: 3,
            maxLength: 200,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Describe the fee purpose...',
              hintStyle: TextStyle(color: Colors.grey),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _showDocumentField = !_showDocumentField);
          if (!_showDocumentField) {
            _additionalFeeDocumentUrl = '';
            _notifyChanges();
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _showDocumentField
                ? _gradientColors[0].withOpacity(0.1)
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.attach_file_rounded,
            color: _showDocumentField ? _gradientColors[0] : Colors.grey,
          ),
        ),
        title: Text(
          'Attach Document',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: _showDocumentField
                    ? _gradientColors[0]
                    : Colors.grey.shade700,
              ),
        ),
        subtitle: Text(
          'Add document URL or reference',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: _showDocumentField
                ? LinearGradient(colors: _gradientColors)
                : null,
            color: _showDocumentField ? null : Colors.grey.shade300,
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: _showDocumentField
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: _gradientColors[0].withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _gradientColors[0].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.link_rounded,
                    color: _gradientColors[0],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Document URL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _additionalFeeDocumentUrl,
              onChanged: (value) {
                setState(() => _additionalFeeDocumentUrl = value);
                _notifyChanges();
              },
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'https://example.com/document.pdf',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: const Icon(
                    Icons.http_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCards() {
    return Row(
      children: [
        Expanded(
          child: _buildIdCard(
            label: 'User ID',
            value: _additionalFeeUserId,
            icon: Icons.person_rounded,
            color: _gradientColors[1],
            onChanged: (value) {
              setState(() => _additionalFeeUserId = value);
              _notifyChanges();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIdCard(
            label: 'Provider ID',
            value: _additionalFeeOnProviderId,
            icon: Icons.business_rounded,
            color: _gradientColors[2],
            onChanged: (value) {
              setState(() => _additionalFeeOnProviderId = value);
              _notifyChanges();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIdCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: value == 0 ? '' : value.toString(),
              onChanged: (text) {
                final id = int.tryParse(text) ?? 0;
                onChanged(id);
              },
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter ID',
                hintStyle: TextStyle(color: color.withOpacity(0.5)),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    FontAwesomeIcons.hashtag,
                    color: color.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildGradientButton(
            text: 'Clear Fee',
            icon: Icons.clear_rounded,
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade400,
            ],
            onPressed: _clearFee,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGradientButton(
            text: widget.isEditing ? 'Update Fee' : 'Save Fee',
            icon: widget.isEditing
                ? Icons.update_rounded
                : Icons.check_circle_rounded,
            colors: _gradientColors,
            onPressed: () {
              // Validate and save
              _notifyChanges();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        widget.isEditing
                            ? 'Fee updated successfully!'
                            : 'Fee saved successfully!',
                      ),
                    ],
                  ),
                  backgroundColor: _gradientColors[1],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[1].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleExpansion() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _clearFee() {
    setState(() {
      _additionalFeeName = '';
      _additionalFeeAmount = 0.0;
      _additionalFeeDescription = '';
      _additionalFeeDocumentUrl = '';
      _additionalFeeUserId = 0;
      _additionalFeeOnProviderId = 0;
      _showDocumentField = false;
    });
    _notifyChanges();

    // Show shimmer effect
    _isLoading = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _isLoading = false);
    });
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
            5,
            (index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                )),
      ),
    );
  }
}
