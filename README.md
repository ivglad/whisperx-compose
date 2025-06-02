# WhisperX Compose

## Описание

Этот проект представляет собой Docker-контейнер для транскрибации и диаризации аудиофайлов с использованием WhisperX. Система автоматически обрабатывает аудиофайлы с поддержкой GPU для ускорения процесса.

## Возможности

- 🎯 **Транскрибация** - преобразование речи в текст
- 👥 **Диаризация** - разделение речи по говорящим
- 🚀 **GPU ускорение** - использование NVIDIA GPU для быстрой обработки
- 📁 **Пакетная обработка** - автоматическая обработка всех файлов в папке
- 🌍 **Русский язык** - оптимизировано для русской речи
- 📊 **JSON вывод** - структурированные результаты

## Требования

### Системные требования

- Docker и Docker Compose
- NVIDIA GPU с поддержкой CUDA
- NVIDIA Container Toolkit

### Токен Hugging Face

Для диаризации требуется токен Hugging Face с принятыми условиями использования моделей pyannote:

1. Создайте аккаунт на [Hugging Face](https://huggingface.co/)
2. Примите условия использования для моделей [pyannote/speaker-diarization-3.1](https://huggingface.co/pyannote/speaker-diarization-3.1) и [pyannote/segmentation-3.0](https://huggingface.co/pyannote/segmentation-3.0)
3. Создайте токен доступа в [настройках](https://huggingface.co/settings/tokens)

## Установка

### 1. Клонирование проекта

```bash
git clone <repository-url>
cd whisperx-compose
```

### 2. Настройка переменных окружения

Создайте файл `.env` в корне проекта:

```bash
# Обязательные параметры
HF_TOKEN=your_huggingface_token_here

# Опциональные параметры (значения по умолчанию)
WHISPER_MODEL_SIZE=large-v3
COMPUTE_TYPE=float16
BATCH_SIZE=8
```

### 3. Подготовка директорий

Структура директорий уже создана:

- `audio_input/` - поместите сюда аудиофайлы для обработки
- `audio_output/` - здесь будут сохранены результаты
- `model_cache/` - кэш загруженных моделей

## Использование

### 1. Подготовка аудиофайлов

Поместите аудиофайлы в папку `audio_input/`:

```bash
cp /path/to/your/audio.wav ./audio_input/
```

Поддерживаемые форматы: WAV, MP3, FLAC, M4A и другие

### 2. Запуск обработки

```bash
docker-compose up
```

### 3. Получение результатов

После завершения обработки результаты будут доступны в папке `audio_output/` в формате JSON.

## Конфигурация

### Параметры модели

| Параметр             | Описание              | Возможные значения                                   | По умолчанию |
| -------------------- | --------------------- | ---------------------------------------------------- | ------------ |
| `WHISPER_MODEL_SIZE` | Размер модели Whisper | tiny, base, small, medium, large, large-v2, large-v3 | large-v3     |
| `COMPUTE_TYPE`       | Тип вычислений        | float16, float32, int8                               | float16      |
| `BATCH_SIZE`         | Размер батча          | 1-32+                                                | 8            |

### Рекомендации по выбору модели

- **tiny/base** - быстро, но менее точно
- **medium** - баланс скорости и качества (рекомендуется)
- **large/large-v3** - максимальное качество, но медленнее

## Структура вывода

Результат обработки сохраняется в JSON формате со следующей структурой:

```json
{
  "segments": [
    {
      "start": 0.0,
      "end": 2.5,
      "text": "Текст сегмента",
      "speaker": "SPEAKER_00",
      "words": [
        {
          "word": "Текст",
          "start": 0.0,
          "end": 0.5,
          "score": 0.95
        }
      ]
    }
  ]
}
```

## Устранение неполадок

### Ошибка "HF_TOKEN не установлена"

- Убедитесь, что создан файл `.env`
- Проверьте корректность токена Hugging Face
- Убедитесь, что приняты условия использования моделей pyannote

### Ошибки GPU

```bash
# Проверьте наличие NVIDIA GPU
nvidia-smi

# Проверьте Docker с GPU
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

### Проблемы с выравниванием слов

Если возникают ошибки выравнивания, раскомментируйте `--no_align` в `entrypoint.sh`:

```bash
# Отредактируйте строку в entrypoint.sh
--batch_size "$BATCH_SIZE" --no_align
```

### Недостаточно памяти GPU

- Уменьшите `BATCH_SIZE` в `.env`
- Используйте меньшую модель (`WHISPER_MODEL_SIZE=small`)
- Измените `COMPUTE_TYPE` на `int8`

## Мониторинг

### Просмотр логов

```bash
docker-compose logs -f whisperx
```

### Использование ресурсов

```bash
# Мониторинг GPU
nvidia-smi

# Мониторинг контейнера
docker stats whisperx_gpu
```

## Остановка и очистка

### Остановка контейнера

```bash
docker-compose down
```

### Очистка кэша моделей

```bash
rm -rf model_cache/*
```

### Полная очистка

```bash
docker-compose down --volumes --rmi all
```

## Лицензия

Проект использует открытые модели и библиотеки. Ознакомьтесь с лицензиями:

- [docker-whisperX](https://github.com/jim60105/docker-whisperX)
- [WhisperX](https://github.com/m-bain/whisperX)
- [OpenAI Whisper](https://github.com/openai/whisper)
- [pyannote.audio](https://github.com/pyannote/pyannote-audio)
