import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/widgets/event_card.dart';

class RegisterEventPage extends StatefulWidget {
  const RegisterEventPage({super.key});

  @override
  State<RegisterEventPage> createState() => _RegisterEventPageState();
}

class _RegisterEventPageState extends State<RegisterEventPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  int? selectedLocationId;
  bool hasSeats = true;

  late final DateTime _previewFallbackDate;
  List<LocationModel> locations = [];
  bool isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _previewFallbackDate = DateTime.now().add(const Duration(days: 7));
    _loadLocations();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final result = await context.read<EventsCubit>().loadLocations();
    setState(() {
      locations = result;
      isLoadingLocations = false;
    });
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDate = dateTime;
      } else {
        endDate = dateTime;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        startDate != null &&
        endDate != null &&
        selectedLocationId != null) {
      final event = EventModel(
        name: nameController.text.trim(),
        startTime: startDate!,
        endTime: endDate!,
        locationId: selectedLocationId!,
        hasSeats: hasSeats,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        imageUrl: imageUrlController.text.trim().isEmpty
            ? null
            : imageUrlController.text.trim(),
      );

      context.read<EventsCubit>().createEvent(event);
    }
  }

  EventModel _buildPreviewEvent() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final imageUrl = imageUrlController.text.trim();

    final startTime = startDate ?? _previewFallbackDate;
    final endTime =
        endDate ?? startTime.add(const Duration(hours: 3, minutes: 30));

    return EventModel(
      name: name.isNotEmpty ? name : 'Seu evento aqui',
      startTime: startTime,
      endTime: endTime,
      locationId: selectedLocationId ?? 0,
      locationName: _selectedLocationName ?? 'Escolha um local',
      hasSeats: hasSeats,
      description: description.isNotEmpty
          ? description
          : 'Adicione uma descrição para deixar o evento mais atrativo.',
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      baseTicketPrice: null,
    );
  }

  String? get _selectedLocationName {
    if (selectedLocationId == null) return null;
    for (final location in locations) {
      if (location.id == selectedLocationId) {
        return location.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IngressinhosAppBar(),
      drawer: const IngressinhosDrawer(),
      backgroundColor: AppColors.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideLayout = constraints.maxWidth >= 960;
          final previewEvent = _buildPreviewEvent();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideLayout ? 1100 : 650,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (isWideLayout)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildFormCard()),
                          const SizedBox(width: 24),
                          Flexible(child: _buildPreviewCard(previewEvent)),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormCard(),
                          const SizedBox(height: 24),
                          _buildPreviewCard(previewEvent),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.accentSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadastrar Evento',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Preencha os detalhes e veja o preview do card em tempo real.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informações principais'),
              const SizedBox(height: 12),
              _buildTextField(
                'Nome do Evento',
                nameController,
                icon: Icons.title_rounded,
                isRequired: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                label: 'Data e Hora de Início',
                selectedDate: startDate,
                onTap: () => _selectDateTime(true),
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                label: 'Data e Hora de Término',
                selectedDate: endDate,
                onTap: () => _selectDateTime(false),
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(height: 22),
              _buildSectionTitle('Local e capacidade'),
              const SizedBox(height: 12),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildSeatsSwitch(),
              const SizedBox(height: 22),
              _buildSectionTitle('Descrição e mídia'),
              const SizedBox(height: 12),
              _buildTextField(
                'Descrição (opcional)',
                descriptionController,
                maxLines: 4,
                icon: Icons.notes_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'URL da Imagem (opcional)',
                imageUrlController,
                icon: Icons.image_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Cadastrar Evento',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(EventModel previewEvent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        const horizontalPadding = 32.0;
        const crossSpacing = 20.0;
        final isNarrow = screenWidth < 640;
        final crossAxisCount = isNarrow ? 1 : 2;
        final totalSpacing = crossSpacing * (crossAxisCount - 1);
        final gridItemWidth =
            (screenWidth - horizontalPadding - totalSpacing) / crossAxisCount;
        final previewWidth =
            gridItemWidth.clamp(0.0, constraints.maxWidth) as double;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Preview do card'),
            const SizedBox(height: 6),
            Text(
              'Veja como o evento aparece na listagem.',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: previewWidth,
              child: AspectRatio(
                aspectRatio: EventCard.aspectRatio,
                child: EventCard(event: previewEvent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationField() {
    if (isLoadingLocations) {
      return InputDecorator(
        decoration: _inputDecoration(
          'Localização',
          icon: Icons.place_rounded,
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando locais...',
              style: GoogleFonts.poppins(color: AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: selectedLocationId,
      isExpanded: true,
      decoration: _inputDecoration(
        'Localização',
        icon: Icons.place_rounded,
      ),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: AppColors.primaryColor,
      ),
      dropdownColor: AppColors.surfaceColor,
      style: GoogleFonts.poppins(
        color: AppColors.primaryText,
        fontSize: 16,
      ),
      items: locations.map((loc) {
        return DropdownMenuItem<int>(
          value: loc.id,
          child: Text(
            loc.name,
            style: GoogleFonts.poppins(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedLocationId = value),
      validator: (value) => value == null ? 'Selecione um local' : null,
    );
  }

  Widget _buildSeatsSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryFocus),
      ),
      child: SwitchListTile.adaptive(
        value: hasSeats,
        onChanged: (val) => setState(() => hasSeats = val),
        activeColor: AppColors.primaryColor,
        title: Text(
          'Evento com assentos',
          style: GoogleFonts.poppins(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          hasSeats
              ? 'Assentos disponíveis para venda.'
              : 'Sem assentos numerados.',
          style: GoogleFonts.poppins(
            color: AppColors.secondaryText,
            fontSize: 13.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildSectionTitle(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16.5,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primaryFocus)
          : null,
      filled: true,
      fillColor: AppColors.backgroundColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondaryFocus),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryFocus,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isRequired = false,
    IconData? icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.poppins(color: AppColors.primaryText),
      decoration: _inputDecoration(label, icon: icon).copyWith(
        alignLabelWithHint: maxLines > 1,
      ),
      validator: isRequired
          ? (value) =>
                value?.trim().isEmpty == true ? '$label obrigatório' : null
          : null,
    );
  }

  Widget _buildDateTimeField({
    required String label,
    DateTime? selectedDate,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(label, icon: icon),
        child: Text(
          selectedDate != null
              ? _formatDateTime(selectedDate)
              : 'Selecione data e hora',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: selectedDate != null
                ? AppColors.primaryText
                : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
