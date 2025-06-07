import 'package:flutter/material.dart';

class CategoryColors {
  // Cores vibrantes inspiradas no app de referência
  static const Map<String, Color> vibrantColors = {
    'abandonar_habito': Color(0xFFFF6B6B), // Vermelho vibrante
    'arte': Color(0xFFFF6B9D),            // Rosa vibrante
    'tarefa': Color(0xFFFF9F40),          // Laranja vibrante
    'meditacao': Color(0xFF9B59B6),       // Roxo vibrante
    'estudos': Color(0xFF3498DB),         // Azul vibrante
    'esportes': Color(0xFF1ABC9C),        // Turquesa vibrante
    'entretenimento': Color(0xFFF39C12),  // Dourado vibrante
    'social': Color(0xFF16A085),          // Verde água vibrante
    'financa': Color(0xFF27AE60),         // Verde vibrante
    'saude': Color(0xFFE74C3C),           // Vermelho coral vibrante
    'trabalho': Color(0xFFE67E22),        // Laranja escuro vibrante
    'nutricao': Color(0xFFF1C40F),        // Amarelo vibrante
    'casa': Color(0xFF9B59B6),            // Roxo médio vibrante
    'ar_livre': Color(0xFF2ECC71),        // Verde claro vibrante
    'outros': Color(0xFF95A5A6),          // Cinza vibrante
  };

  // Cores para modo escuro (versões mais saturadas)
  static const Map<String, Color> darkModeColors = {
    'abandonar_habito': Color(0xFFFF5252), 
    'arte': Color(0xFFFF4081),            
    'tarefa': Color(0xFFFF6E40),          
    'meditacao': Color(0xFFBA68C8),       
    'estudos': Color(0xFF5C6BC0),         
    'esportes': Color(0xFF4DB6AC),        
    'entretenimento': Color(0xFFFFB74D),  
    'social': Color(0xFF4DB6AC),          
    'financa': Color(0xFF66BB6A),         
    'saude': Color(0xFFEF5350),           
    'trabalho': Color(0xFFFF7043),        
    'nutricao': Color(0xFFFFD54F),        
    'casa': Color(0xFFAB47BC),            
    'ar_livre': Color(0xFF81C784),        
    'outros': Color(0xFF90A4AE),          
  };

  // Função para obter cor baseada no tema
  static Color getCategoryColor(String categoryName, bool isDarkMode) {
    final normalizedName = _normalizeCategoryName(categoryName);
    
    if (isDarkMode) {
      return darkModeColors[normalizedName] ?? darkModeColors['outros']!;
    } else {
      return vibrantColors[normalizedName] ?? vibrantColors['outros']!;
    }
  }

  // Normaliza o nome da categoria para a chave do mapa
  static String _normalizeCategoryName(String name) {
    final mapping = {
      'Abandonar hábito': 'abandonar_habito',
      'Arte': 'arte',
      'Tarefa': 'tarefa',
      'Meditação': 'meditacao',
      'Estudos': 'estudos',
      'Esportes': 'esportes',
      'Entretenimento': 'entretenimento',
      'Social': 'social',
      'Finança': 'financa',
      'Saúde': 'saude',
      'Trabalho': 'trabalho',
      'Nutrição': 'nutricao',
      'Casa': 'casa',
      'Ar livre': 'ar_livre',
      'Outros': 'outros',
    };
    
    return mapping[name] ?? 'outros';
  }

  // Cores para badges e tags
  static const Color premiumBadgeColor = Color(0xFFFFD700); // Dourado
  static const Color habitTagColor = Color(0xFF9B59B6);     // Roxo
  static const Color taskTagColor = Color(0xFFFF9F40);      // Laranja
}