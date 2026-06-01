import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/formatters/money_input_formatter.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_state.dart';
import 'package:ingressinhos_frontend/features/home/presentation/widgets/event_card.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final baseTicketPriceController = TextEditingController();
  final premiumTicketPriceController = TextEditingController();
  final vipTicketPriceController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  DateTime? salesStartsAt;
  DateTime? salesEndsAt;
  int? selectedLocationId;
  bool hasSeats = false;

  late final DateTime _previewFallbackDate;
  List<LocationModel> locations = [];
  bool isLoadingLocations = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _previewFallbackDate = DateTime.now().add(const Duration(days: 7));
    _prefillForm(widget.event);
    _loadLocations();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    baseTicketPriceController.dispose();
    premiumTicketPriceController.dispose();
    vipTicketPriceController.dispose();
    super.dispose();
  }

  void _prefillForm(EventModel event) {
    nameController.text = event.name;
    descriptionController.text = event.description ?? '';
    imageUrlController.text = event.imageUrl ?? '';
    if (event.baseTicketPrice != null) {
      baseTicketPriceController.text = event.baseTicketPrice!.toStringAsFixed(
        2,
      );
    }
    if (event.premiumTicketPrice != null) {
      premiumTicketPriceController.text = event.premiumTicketPrice!
          .toStringAsFixed(2);
    }
    if (event.vipTicketPrice != null) {
      vipTicketPriceController.text = event.vipTicketPrice!.toStringAsFixed(2);
    }

    startDate = event.startTime;
    endDate = event.endTime;
    salesStartsAt = event.salesStartsAt;
    salesEndsAt = event.salesEndsAt;
    selectedLocationId = event.locationId;
    hasSeats = event.hasSeats;
  }

  Future<void> _loadLocations() async {
    final eventsCubit = context.read<EventsCubit>();
    final result = await eventsCubit.loadLocations();
    if (!mounted) return;
    setState(() {
      locations = result;
      isLoadingLocations = false;
    });
  }

  Future<void> _selectDateTime(bool isStart) async {
    final current = isStart ? startDate : endDate;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;
    if (!mounted) return;

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

  Future<void> _selectDateTimeSales(bool isStart) async {
    final current = isStart ? salesStartsAt : salesEndsAt;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;
    if (!mounted) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        salesStartsAt = dateTime;
      } else {
        salesEndsAt = dateTime;
      }
    });
  }

  Future<void> _submit() async {
    final eventId = widget.event.id;
    if (eventId == null) {
      showErrorSnackBar(context, 'Evento invalido', true);
      return;
    }

    if (_formKey.currentState!.validate() &&
        startDate != null &&
        endDate != null &&
        selectedLocationId != null) {
      final event = EventModel(
        id: eventId,
        ticketId: widget.event.ticketId,
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
        baseTicketPrice: parseMoney(baseTicketPriceController.text),
        premiumTicketPrice: parseMoney(premiumTicketPriceController.text),
        vipTicketPrice: parseMoney(vipTicketPriceController.text),
        isActive: widget.event.isActive ?? true,
        salesStartsAt: salesStartsAt,
        salesEndsAt: salesEndsAt,
      );

      context.read<EventsCubit>().updateEvent(eventId, event);
    } else {
      showErrorSnackBar(context, 'Preencha todos os campos obrigatorios', true);
    }
  }

  Future<void> _confirmDelete() async {
    final eventId = widget.event.id;
    if (eventId == null) {
      showErrorSnackBar(context, 'Evento invalido', true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: Text(
            'Excluir evento?',
            style: GoogleFonts.poppins(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Essa ação remove o evento da loja. Eventos com pedidos ou ingressos vinculados não podem ser excluídos.',
            style: GoogleFonts.poppins(color: AppColors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: AppColors.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Excluir',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    context.read<EventsCubit>().deleteEvent(eventId);
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
          : 'Adicione uma descricao para deixar o evento mais atrativo.',
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      baseTicketPrice: baseTicketPriceController.text.trim().isNotEmpty
          ? parseMoney(baseTicketPriceController.text)
          : null,
      premiumTicketPrice: premiumTicketPriceController.text.trim().isNotEmpty
          ? parseMoney(premiumTicketPriceController.text)
          : null,
      vipTicketPrice: vipTicketPriceController.text.trim().isNotEmpty
          ? parseMoney(vipTicketPriceController.text)
          : null,
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
    return IngressinhosScaffold(
      appBar: const IngressinhosAppBar(
        title: 'Editar evento',
        titleFontSize: 22,
        showCartAction: false,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<EventsCubit, EventsState>(
        listener: (context, state) {
          if (state is EventsUpdated) {
            setState(() => _isSaving = false);
            showErrorSnackBar(context, 'Evento atualizado com sucesso', false);
            Navigator.pop(context, true);
          }

          if (state is EventsDeleted) {
            setState(() => _isDeleting = false);
            showErrorSnackBar(context, 'Evento excluido com sucesso', false);
            Navigator.pop(context, true);
          }

          if (state is EventUpdating) {
            setState(() => _isSaving = true);
          }

          if (state is EventDeleting) {
            setState(() => _isDeleting = true);
          }

          if (state is EventsError) {
            setState(() {
              _isSaving = false;
              _isDeleting = false;
            });
            showErrorSnackBar(context, state.message, true);
          }
        },
        child: LayoutBuilder(
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
                            _buildPreviewCard(previewEvent),
                            const SizedBox(height: 24),
                            _buildFormCard(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
              _buildSectionTitle('Informacoes principais'),
              const SizedBox(height: 12),
              _buildTextField(
                'Nome do Evento (obrigatorio)',
                nameController,
                icon: Icons.title_rounded,
                isRequired: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                label: 'Data e Hora de Inicio (obrigatorio)',
                selectedDate: startDate,
                onTap: () => _selectDateTime(true),
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                label: 'Data e Hora de Termino (obrigatorio)',
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
              _buildSectionTitle('Valores dos ingressos'),
              const SizedBox(height: 12),
              _buildTextField(
                'Preco do Ingresso Base',
                baseTicketPriceController,
                icon: Icons.confirmation_num_rounded,
                isRequired: true,
                isMoney: true,
                onChanged: (_) => setState(() {}),
              ),
              if (hasSeats) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  'Preco do Ingresso Premium',
                  premiumTicketPriceController,
                  icon: Icons.confirmation_num_rounded,
                  isMoney: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Preco do Ingresso VIP',
                  vipTicketPriceController,
                  icon: Icons.confirmation_num_rounded,
                  isMoney: true,
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),
              _buildDateTimeField(
                label: 'Data de Inicio das Vendas (obrigatorio)',
                selectedDate: salesStartsAt,
                onTap: () => _selectDateTimeSales(true),
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(height: 16),
              _buildDateTimeField(
                label: 'Data de Termino das Vendas (obrigatorio)',
                selectedDate: salesEndsAt,
                onTap: () => _selectDateTimeSales(false),
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(height: 22),
              _buildSectionTitle('Descricao e midia'),
              const SizedBox(height: 12),
              _buildTextField(
                'Descricao (opcional)',
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
                  onPressed: _isSaving || _isDeleting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Salvar alteracoes',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving || _isDeleting ? null : _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: const BorderSide(color: AppColors.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.errorColor,
                          ),
                        )
                      : const Icon(Icons.delete_outline_rounded),
                  label: Text(
                    _isDeleting ? 'Excluindo...' : 'Excluir evento',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
        final previewWidth = gridItemWidth.clamp(0.0, constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildSectionTitle('Preview do card')),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Veja como o evento aparece na listagem.',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: AppColors.secondaryText,
                ),
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
        decoration: _inputDecoration('Localizacao', icon: Icons.place_rounded),
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
      initialValue: selectedLocationId,
      isExpanded: true,
      decoration: _inputDecoration(
        'Localizacao (obrigatorio)',
        icon: Icons.place_rounded,
      ),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
      dropdownColor: AppColors.surfaceColor,
      style: GoogleFonts.poppins(color: AppColors.primaryText, fontSize: 16),
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
        onChanged: null,
        activeThumbColor: AppColors.primaryColor,
        title: Text(
          'Assentos numerados',
          style: GoogleFonts.poppins(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          hasSeats
              ? 'Assentos disponiveis para venda.'
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
    bool isRequired = false,
    bool isMoney = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isMoney
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      inputFormatters: isMoney
          ? const <TextInputFormatter>[MoneyInputFormatter()]
          : null,
      style: GoogleFonts.poppins(color: AppColors.primaryText),
      onChanged: onChanged,
      decoration: _inputDecoration(label, icon: icon),
      validator: (value) {
        if (isMoney) {
          return validateMoneyField(
            value,
            isRequired: isRequired,
            emptyMessage: 'Campo obrigatorio',
          );
        }

        if (!isRequired) return null;
        if (value == null || value.trim().isEmpty) {
          return 'Campo obrigatorio';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          style: GoogleFonts.poppins(color: AppColors.primaryText),
          decoration: _inputDecoration(
            label,
            icon: icon,
            suffixIcon: Icons.calendar_today_rounded,
          ),
          controller: TextEditingController(
            text: selectedDate == null
                ? ''
                : '${selectedDate.day.toString().padLeft(2, '0')}/'
                      '${selectedDate.month.toString().padLeft(2, '0')}/'
                      '${selectedDate.year} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obrigatorio';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryColor,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primaryColor)
          : null,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: AppColors.primaryColor)
          : null,
      filled: true,
      fillColor: AppColors.backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryFocus, width: 1.4),
      ),
    );
  }
}
