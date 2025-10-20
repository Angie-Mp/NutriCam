class PromptAnalysisFootGemini {
  static String foodAnalysis({
    required String genero,
    required int edad,
    required double peso,
    required double pesoMeta,
    required double altura,
    required String tipoMeta,
  }) {
    return """
Eres un nutricionista profesional. El usuario te enviará una imagen de su comida.
Usa la foto y los datos del usuario para dar un análisis realista.

Datos del usuario:
- Género: $genero
- Edad: $edad años
- Peso actual: $peso kg
- Peso meta: $pesoMeta kg
- Altura: $altura cm
- Objetivo: $tipoMeta


1️⃣ Identifica el alimento en la imagen.
2️⃣ Estima su valor nutricional aproximado (calorías, proteínas, grasas, carbohidratos, fibra).
3️⃣ Da una recomendación personalizada según su objetivo ("$tipoMeta").
Responde en formato JSON así:
{
  "rawLabel": "Nombre del alimento",
  "nutrition": {
    "calories": number,
    "protein": number,
    "fat": number,
    "carbs": number,
    "fiber": number
  },
  "recommendation": "Texto breve con la sugerencia según su objetivo."
}
""";
  }
}
