import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_button.dart';

class EditStoryScreen extends StatefulWidget {
  final String storyId;

  const EditStoryScreen({required this.storyId, super.key});

  @override
  State<EditStoryScreen> createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends State<EditStoryScreen> {
  bool isMature = false;
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    // Buscar la historia en publicadas o borradores (mock logic)
    final allWorks = [...MockData.myAuthoredWorks, ...MockData.myDraftWorks];
    final work = widget.storyId == 'new'
        ? null
        : allWorks.firstWhere((w) => w.id == widget.storyId, orElse: () => allWorks.first);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.storyId == 'new' ? 'Crear Historia' : 'Editar Historia',
            style: KotobaTypography.headlineMd),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: KotobaButton(
              label: 'Guardar',
              onPressed: () {},
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Portada
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: work?.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: work!.coverUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.surfaceHigh,
                          child: const Icon(Icons.add_photo_alternate, color: AppColors.onSurfaceVariant),
                        ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  'Editar la Portada de la Historia',
                  style: KotobaTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildSectionTitle('Título de la Historia *'),
          _buildTextField(work?.title ?? ''),
          
          _buildSectionTitle('Descripción de la Historia *'),
          _buildTextField(work?.synopsis ?? '', maxLines: 3),

          _buildSectionTitle('Idioma'),
          _buildDropdown('Español'),

          _buildSectionTitle('Tipo de historia *'),
          _buildDropdown('NUEVO'),

          _buildSectionTitle('Etiquetas *'),
          _buildTextField(work?.tags.join(', ') ?? 'Ej: romance, fantasía...'),

          _buildSectionTitle('Derechos de autor'),
          _buildDropdown('Todos los Derechos Reservados'),

          // Switches
          _buildSwitchTile(
            title: 'Madura',
            subtitle: 'Tu historia es apta para público maduro.',
            value: isMature,
            onChanged: (v) => setState(() => isMature = v),
          ),
          _buildSwitchTile(
            title: 'Historia Completa',
            subtitle: 'Marca si la historia ya está terminada.',
            value: isCompleted,
            onChanged: (v) => setState(() => isCompleted = v),
          ),

          const SizedBox(height: 32),

          // Tabla de contenidos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tabla de Contenidos', style: KotobaTypography.headlineMd),
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),

          // Capítulos existentes (mock)
          if (work != null) ...[
            _buildChapterItem('Parte 1: El comienzo', 'Borrador - actualizado hoy'),
            const Divider(color: AppColors.outlineVariant),
          ],

          const SizedBox(height: 16),
          // Botón Añadir Parte
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.outlineVariant,
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.add, color: AppColors.onSurfaceVariant),
                  SizedBox(height: 8),
                  Text('AÑADIR PARTE NUEVA', style: KotobaTypography.labelMd),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: KotobaTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(String initialValue, {int maxLines = 1}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: KotobaTypography.bodyMd,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant)),
      ),
    );
  }

  Widget _buildDropdown(String value) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: [
        DropdownMenuItem(value: value, child: Text(value)),
      ],
      onChanged: (v) {},
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant)),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KotobaTypography.bodyLg),
                const SizedBox(height: 4),
                Text(subtitle, style: KotobaTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.action,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: KotobaTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: KotobaTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
