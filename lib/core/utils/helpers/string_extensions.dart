/*extension para eliminar acentos de las cadenas de texto, 
útil para impresión en tickets donde los caracteres 
acentuados pueden no ser compatibles con la impresora térmica.*/
extension StringExtensions on String {
  String get withoutDiacritics {
    const withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    String result = this;
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result;
  }
}
