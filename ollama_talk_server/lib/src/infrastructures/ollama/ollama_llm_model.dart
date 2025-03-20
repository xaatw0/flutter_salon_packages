import 'package:ollama_talk_common/ollama_talk_common.dart';

class OllamaLlmModel extends LlmModel {
  const OllamaLlmModel(super.value);

  ///  Llama-3-ELYZA-JP-8B
  static const kElyzaJp8b = OllamaLlmModel('elyza:jp8b');

  ///  楽天グループが 2025 年 2 月に公開した、パラメータ数 1.5B
  /// https://zenn.dev/hellorusk/books/e56548029b391f/viewer/ollama11
  static const kRakuten20Mini15b =
      OllamaLlmModel('yuiseki/rakutenai-2.0-mini:1.5b-instruct');

  /// DeepSeek 社の R1 モデルを日本語向けに最適化したもの
  static const kDeepSeekR1Jp14b =
      OllamaLlmModel('yuma/DeepSeek-R1-Distill-Qwen-Japanese:14b');

  /// Tanuki: 東大の松尾研が 2024 年度上期に主催していた LLM 開発プロジェクトにおいて構築された LLM
  static const kTanuki = OllamaLlmModel('7shi/tanuki-dpo-v1.0');

  ///
  static const kFugaku13b = OllamaLlmModel('nebel/fugaku-llm:13b-instruct');

  static const kQwq32B = OllamaLlmModel('milkey/QwQ-32B-0305:q4_K_M');
}
