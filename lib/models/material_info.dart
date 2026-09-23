import 'package:flutter/material.dart';

class MaterialInfo {
  final int id;
  final String nameEn;
  final String namePt;
  final String conamaColorName;
  final String conamaHexColor;
  final String conamaTextColor;
  final String icon;
  final bool recyclable;
  final bool compostable;
  final String disposalBin;
  final String generalInstructions;
  final List<String> preparationSteps;
  final List<String> examples;
  final String multiMaterialNotes;
  final String academicModelNotes;

  const MaterialInfo({
    required this.id,
    required this.nameEn,
    required this.namePt,
    required this.conamaColorName,
    required this.conamaHexColor,
    required this.conamaTextColor,
    required this.icon,
    required this.recyclable,
    required this.compostable,
    required this.disposalBin,
    required this.generalInstructions,
    required this.preparationSteps,
    required this.examples,
    required this.multiMaterialNotes,
    required this.academicModelNotes,
  });

  Color get color {
    final hexCode = conamaHexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Color get textColor {
    final hexCode = conamaTextColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    return MaterialInfo(
      id: json['id'] as int? ?? 0,
      nameEn: json['name_en'] as String? ?? '',
      namePt: json['name_pt'] as String? ?? '',
      conamaColorName: json['conama_color_name'] as String? ?? 'Cinza',
      conamaHexColor: json['conama_hex_color'] as String? ?? '#757575',
      conamaTextColor: json['conama_text_color'] as String? ?? '#FFFFFF',
      icon: json['icon'] as String? ?? 'recycling',
      recyclable: json['recyclable'] as bool? ?? true,
      compostable: json['compostable'] as bool? ?? false,
      disposalBin: json['disposal_bin'] as String? ?? 'Lixeira Comum',
      generalInstructions: json['general_instructions'] as String? ?? '',
      preparationSteps: (json['preparation_steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      multiMaterialNotes: json['multi_material_notes'] as String? ?? '',
      academicModelNotes: json['academic_model_notes'] as String? ?? '',
    );
  }
}
