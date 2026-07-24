import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../../core/widgets/common/kotoba_text_field.dart';
import '../providers/auth_providers.dart';

const _countries = [
  'México', 'Argentina', 'Colombia', 'Chile', 'Perú',
  'Ecuador', 'Venezuela', 'Bolivia', 'Paraguay', 'Uruguay',
  'Costa Rica', 'El Salvador', 'Guatemala', 'Honduras', 'Nicaragua',
  'Panamá', 'República Dominicana', 'Cuba', 'Puerto Rico',
  'España', 'Estados Unidos', 'Brasil', 'Otro',
];

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _usernameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _country;
  bool _submitting = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de usuario es obligatorio')),
      );
      return;
    }

    setState(() => _submitting = true);

    final api = ref.read(apiClientProvider);
    final body = <String, dynamic>{'username': username};
    if (_ageCtrl.text.trim().isNotEmpty) {
      body['age'] = int.tryParse(_ageCtrl.text.trim());
    }
    if (_country != null) body['country'] = _country;

    final result = await api.put('/users/me', data: body);
    setState(() => _submitting = false);

    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        ref.read(userProfileCompleteProvider.notifier).state = true;
        context.go('/home');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Completa tu perfil',
                style: KotobaTypography.headlineLg.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Antes de empezar, cuéntanos un poco sobre ti',
                style: KotobaTypography.bodyMd.copyWith(
                  color: c.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              KotobaTextField(
                label: AppStrings.usernameLabel,
                prefixIcon: Icons.person_outline,
                controller: _usernameCtrl,
              ),
              const SizedBox(height: 16),
              KotobaTextField(
                label: 'Edad',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.cake_outlined,
                controller: _ageCtrl,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _country,
                decoration: const InputDecoration(
                  labelText: 'País',
                  prefixIcon: Icon(Icons.public_outlined),
                  border: UnderlineInputBorder(),
                ),
                style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                dropdownColor: c.surfaceHigh,
                items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
                onChanged: (v) => setState(() => _country = v),
              ),
              const SizedBox(height: 32),

              KotobaButton(
                label: 'Guardar',
                onPressed: _submitting ? null : _submit,
                isLoading: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
