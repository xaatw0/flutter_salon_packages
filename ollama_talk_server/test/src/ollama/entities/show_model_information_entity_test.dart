import 'package:ollama_talk_server/src/ollama/entities/show_model_information_entity.dart';
import 'package:test/test.dart';

void main() {
  group('ModelData fromJson', () {
    test('should correctly parse JSON data', () {
      // Sample JSON data
      const jsonData = {
        "modelfile":
            "# Modelfile generated by \"ollama show\"\n# To build a new Modelfile based on this one, replace the FROM line with:\n# FROM llava:latest\n\nFROM /Users/matt/.ollama/models/blobs/sha256:200765e1283640ffbd013184bf496e261032fa75b99498a9613be4e94d63ad52\nTEMPLATE \"\"\"{{ .System }}\nUSER: {{ .Prompt }}\nASSISTANT: \"\"\"\nPARAMETER num_ctx 4096\nPARAMETER stop \"\u003c/s\u003e\"\nPARAMETER stop \"USER:\"\nPARAMETER stop \"ASSISTANT:\"",
        "parameters":
            "num_keep 24\nstop \"<|start_header_id|>\"\nstop \"<|end_header_id|>\"\nstop \"<|eot_id|>\"",
        "template":
            "{{ if .System }}<|start_header_id|>system<|end_header_id|>\n\n{{ .System }}<|eot_id|>{{ end }}{{ if .Prompt }}<|start_header_id|>user<|end_header_id|>\n\n{{ .Prompt }}<|eot_id|>{{ end }}<|start_header_id|>assistant<|end_header_id|>\n\n{{ .Response }}<|eot_id|>",
        "details": {
          "parent_model": "",
          "format": "gguf",
          "family": "llama",
          "families": ["llama"],
          "parameter_size": "8.0B",
          "quantization_level": "Q4_0"
        },
        "model_info": {
          "general.architecture": "llama",
          "general.file_type": 2,
          "general.parameter_count": 8030261248,
          "general.quantization_version": 2,
          "llama.attention.head_count": 32,
          "llama.attention.head_count_kv": 8,
          "llama.attention.layer_norm_rms_epsilon": 0.00001,
          "llama.block_count": 32,
          "llama.context_length": 8192,
          "llama.embedding_length": 4096,
          "llama.feed_forward_length": 14336,
          "llama.rope.dimension_count": 128,
          "llama.rope.freq_base": 500000,
          "llama.vocab_size": 128256,
          "tokenizer.ggml.bos_token_id": 128000,
          "tokenizer.ggml.eos_token_id": 128009,
          "tokenizer.ggml.model": "gpt2",
          "tokenizer.ggml.pre": "llama-bpe",
          "tokenizer.ggml.merges": [],
          "tokenizer.ggml.token_type": [],
          "tokenizer.ggml.tokens": []
        }
      };

      // Create instance from JSON
      final modelData = ShowModelInformationEntity.fromJson(jsonData);

      // Assertions for top-level fields
      expect(modelData.modelfile,
          "# Modelfile generated by \"ollama show\"\n# To build a new Modelfile based on this one, replace the FROM line with:\n# FROM llava:latest\n\nFROM /Users/matt/.ollama/models/blobs/sha256:200765e1283640ffbd013184bf496e261032fa75b99498a9613be4e94d63ad52\nTEMPLATE \"\"\"{{ .System }}\nUSER: {{ .Prompt }}\nASSISTANT: \"\"\"\nPARAMETER num_ctx 4096\nPARAMETER stop \"\u003c/s\u003e\"\nPARAMETER stop \"USER:\"\nPARAMETER stop \"ASSISTANT:\"");
      expect(modelData.parameters,
          'num_keep 24\nstop "<|start_header_id|>"\nstop "<|end_header_id|>"\nstop "<|eot_id|>"');
      expect(modelData.template,
          '{{ if .System }}<|start_header_id|>system<|end_header_id|>\n\n{{ .System }}<|eot_id|>{{ end }}{{ if .Prompt }}<|start_header_id|>user<|end_header_id|>\n\n{{ .Prompt }}<|eot_id|>{{ end }}<|start_header_id|>assistant<|end_header_id|>\n\n{{ .Response }}<|eot_id|>');

      // Assertions for details fields
      expect(modelData.details.parentModel, "");
      expect(modelData.details.format, "gguf");
      expect(modelData.details.family, "llama");
      expect(modelData.details.families, ["llama"]);
      expect(modelData.details.parameterSize, "8.0B");
      expect(modelData.details.quantizationLevel, "Q4_0");

      // Assertions for model_info fields
      expect(modelData.modelInfo.architecture, "llama");
      expect(modelData.modelInfo.fileType, 2);
      expect(modelData.modelInfo.parameterCount, 8030261248);
      expect(modelData.modelInfo.quantizationVersion, 2);
      expect(modelData.modelInfo.headCount, 32);
      expect(modelData.modelInfo.headCountKv, 8);
      expect(modelData.modelInfo.layerNormRmsEpsilon, 0.00001);
      expect(modelData.modelInfo.blockCount, 32);
      expect(modelData.modelInfo.contextLength, 8192);
      expect(modelData.modelInfo.embeddingLength, 4096);
      expect(modelData.modelInfo.feedForwardLength, 14336);
      expect(modelData.modelInfo.dimensionCount, 128);
      expect(modelData.modelInfo.freqBase, 500000);
      expect(modelData.modelInfo.vocabSize, 128256);
      expect(modelData.modelInfo.bosTokenId, 128000);
      expect(modelData.modelInfo.eosTokenId, 128009);
      expect(modelData.modelInfo.model, "gpt2");
      expect(modelData.modelInfo.pre, "llama-bpe");
    });
  });
}
