#!/bin/bash
set -e

if [ -z "$HF_TOKEN" ]; then
  echo "Ошибка: Переменная окружения HF_TOKEN не установлена. Она необходима для диаризации." >&2
  echo "Пожалуйста, установите ее в .env файле и примите условия использования моделей pyannote на Hugging Face." >&2
  exit 1
fi

echo "Запуск обработки файлов из /input_audio..."
echo "Модель Whisper: $WHISPER_MODEL_SIZE, Тип вычислений: $COMPUTE_TYPE, Размер батча: $BATCH_SIZE"

# Проверка наличия файлов в /input_audio
if [ -z "$(ls -A /input_audio)" ]; then
  echo "Папка /input_audio пуста. Поместите аудиофайлы для обработки." >&2
  exit 0
fi

for f in /input_audio/*; do
  if [ -f "$f" ]; then
    filename=$(basename -- "$f")
    echo "--- Обработка файла: $filename ---"
    whisperx "$f" \
      --model "$WHISPER_MODEL_SIZE" \
      --language ru \
      --diarize \
      --hf_token "$HF_TOKEN" \
      --output_dir /output_audio \
      --output_format json \
      --device cuda \
      --compute_type "$COMPUTE_TYPE" \
      --batch_size "$BATCH_SIZE" # --no_align # Раскомментируйте, если возникают проблемы с выравниванием на уровне слов
    echo "--- Файл $filename обработан. Результат в /output_audio ---"
  else
    echo "Пропуск $f, не является файлом."
  fi
done

echo "Все файлы обработаны."
exit 0 