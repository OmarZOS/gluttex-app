library locator;

import 'package:get_it/get_it.dart';

class Locator {
  static final GetIt _getIt = GetIt.instance;

  static void setup() {
    // Register your dependencies here
    // Example:
    // _getIt.registerSingleton<MyService>(MyService());
  }

  static T get<T extends Object>() {
    return _getIt.get<T>();
  }

  static T? getOrDefault<T extends Object>({T? defaultValue}) {
    return _getIt.get<T>() ?? defaultValue;
  }

  // Method to register a service provider instance
  static void registerSingletonService<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  static void registerFactory<T extends Object>(FactoryFunc<T> factoryFunc) {
    _getIt.registerFactory<T>(factoryFunc);
  }
}
