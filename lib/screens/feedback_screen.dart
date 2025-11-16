import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
    super.dispose();
  }

  void _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor escribe tu comentario'),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    // Preparar el email
    final String emailAddress = 'mmales76@gmail.com';
    final String subject = 'Comentario - Pomodoro App ($_selectedCategory)';
    final String body = '''
Categoría: $_selectedCategory

Comentario:
${_feedbackController.text.trim()}
''';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      final bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Abriendo email...'),
              backgroundColor: AppColors.sky,
              duration: Duration(seconds: 2),
            ),
          );

          // Limpiar y volver
          _feedbackController.clear();
          Navigator.of(context).pop();
        }
      } else {
        throw 'No se pudo abrir el cliente de email';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir email'),
            backgroundColor: AppColors.destructive,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
                backgroundColor: AppColors.sky,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                elevation: 2,
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
