import 'package:flutter/material.dart';
import 'package:pomodoro_app/global/app_colors.dart';
import 'package:pomodoro_app/global/app_typography.dart';
import 'package:pomodoro_app/global/app_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════════
// FEEDBACK SCREEN - PANTALLA DE COMENTARIOS
// ═══════════════════════════════════════════════════════════════════════════════════
//
// Permite a los usuarios enviar comentarios sobre la app
//
// ═══════════════════════════════════════════════════════════════════════════════════

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedCategory = 'Sugerencia';

  final List<String> _categories = [
    'Sugerencia',
    'Error/Bug',
    'Mejora',
    'Otro',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor escribe tu comentario'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    // TODO: Aquí implementarías el envío real del comentario
    // Por ejemplo, enviar a un servidor, correo electrónico, etc.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Gracias por tu comentario'),
        backgroundColor: AppColors.primary,
      ),
    );

    // Limpiar y volver
    _feedbackController.clear();
    _emailController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Enviar comentarios'),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          // ═══════════════════════════════════════════════════════════════════════════
          // DESCRIPCIÓN
          // ═══════════════════════════════════════════════════════════════════════════
          Card(
            color: AppColors.sky.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.sky),
                  SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: Text(
                      'Tu opinión nos ayuda a mejorar la app',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // CATEGORÍA
          // ═══════════════════════════════════════════════════════════════════════════
          Text(
            'Categoría',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                underline: SizedBox(),
                dropdownColor: AppColors.card,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // EMAIL (OPCIONAL)
          // ═══════════════════════════════════════════════════════════════════════════
          Text(
            'Email (opcional)',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Card(
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'tu@email.com',
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.sky),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // COMENTARIO
          // ═══════════════════════════════════════════════════════════════════════════
          Text(
            'Tu comentario',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Card(
            child: TextField(
              controller: _feedbackController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Escribe tu comentario aquí...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
              ),
            ),
          ),

          SizedBox(height: AppConstants.paddingLarge),

          // ═══════════════════════════════════════════════════════════════════════════
          // BOTÓN ENVIAR
          // ═══════════════════════════════════════════════════════════════════════════
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Text(
                'Enviar comentario',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
