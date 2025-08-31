// lib/services/llm_service.dart
import 'dart:async';
import 'package:llama_cpp/llama_cpp.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LLMService {
  LlamaCpp? _llama;
  bool _ready = false;

  Future<void> init(String modelPath) async {
    if (_ready) return;
    _llama = await LlamaCpp.load(modelPath, verbose: false);
    _ready = true;
  }

  /// Génère la réponse complète (attend la fin)
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    if (!_ready) throw Exception('LLM not initialized');
    final answerStream = _llama!.answer(prompt, maxTokens: maxTokens);
    final result = await answerStream.join('');
    return result;
  }

  /// Génère en streaming (utile pour afficher token par token)
  Stream<String> generateStream(String prompt, {int maxTokens = 256}) async* {
    if (!_ready) throw Exception('LLM not initialized');
    await for (final chunk in _llama!.answer(prompt, maxTokens: maxTokens)) {
      yield chunk;
    }
  }

  Future<void> dispose() async {
    await _llama?.dispose();
    _ready = false;
  }
}

