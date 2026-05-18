import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';

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

  List<LocationModel> locations = [];
  bool isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
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
      if (isStart)
        startDate = dateTime;
      else
        endDate = dateTime;
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

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 20);

    return Scaffold(
      appBar: const IngressinhosAppBar(),
      drawer: const IngressinhosDrawer(),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cadastrar Evento',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(height: 40),

                _buildTextField(
                  'Nome do Evento',
                  nameController,
                  isRequired: true,
                ),

                space,

                _buildDateTimeField(
                  label: 'Data e Hora de Início',
                  selectedDate: startDate,
                  onTap: () => _selectDateTime(true),
                ),

                space,

                _buildDateTimeField(
                  label: 'Data e Hora de Término',
                  selectedDate: endDate,
                  onTap: () => _selectDateTime(false),
                ),

                space,

                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<int>(
                    value: selectedLocationId,
                    isExpanded: true, // ← importante para não cortar o texto
                    decoration: InputDecoration(
                      labelText: 'Localização',
                      labelStyle: GoogleFonts.poppins(
                        color: AppColors.secondaryText,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryFocus,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryColor,
                    ),
                    dropdownColor:
                        AppColors.backgroundColor, // fundo do dropdown
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
                    onChanged: (value) =>
                        setState(() => selectedLocationId = value),
                    validator: (value) =>
                        value == null ? 'Selecione um local' : null,
                  ),
                ),

                space,

                SizedBox(
                  width: 300,
                  child: SwitchListTile(
                    title: Text(
                      'Evento com assentos',
                      style: GoogleFonts.poppins(color: AppColors.primaryText),
                    ),
                    value: hasSeats,
                    onChanged: (val) => setState(() => hasSeats = val),
                    activeColor: AppColors.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                space,

                _buildTextField(
                  'Descrição (opcional)',
                  descriptionController,
                  maxLines: 4,
                ),

                space,

                _buildTextField('URL da Imagem (opcional)', imageUrlController),

                const SizedBox(height: 40),

                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.primaryText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cadastrar Evento',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: AppColors.primaryText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryFocus,
              width: 2,
            ),
          ),
        ),
        validator: isRequired
            ? (value) =>
                  value?.trim().isEmpty == true ? '$label obrigatório' : null
            : null,
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 300,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryFocus,
                width: 2,
              ),
            ),
          ),
          child: Text(
            selectedDate != null
                ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year} '
                      '${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}'
                : 'Selecione data e hora',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: selectedDate != null ? AppColors.primaryText : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
