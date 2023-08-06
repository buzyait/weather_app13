class ApiConst {
  static const String apiKey = 'edeec702d15a4f2cd857e9917031d215';
  static const String cityName = 'moscow';
  static const String api =
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=edeec702d15a4f2cd857e9917031d215';
  static String getIcon(String icon, int size) {
    return 'http://openweathermap.org/img/wn/$icon@${size}x.png';
  }
}
