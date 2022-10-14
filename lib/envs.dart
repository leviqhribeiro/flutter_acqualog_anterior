
enum Environment { DEV, PROD }

class Constants {
  static Map<String, dynamic> _config;

  static void setEnvironment(Environment env) {
    switch (env) {
      case Environment.DEV:
        _config = _Config.debugConstants;
        break;
      case Environment.PROD:
        _config = _Config.prodConstants;
        break;
    }
  }

  static get baseUrl {
    return _config[_Config.BASE_URL];
  }
}

class _Config {
  static const BASE_URL = "BASE_URL";

  static Map<String, dynamic> debugConstants = {
    BASE_URL: 'https://canteiro.homologacao.net.br/api/',
  };

  static Map<String, dynamic> prodConstants = {
    BASE_URL: "https://app.acqualog.com/api/",
  };
}