# Примеры использования WhisperX

## Быстрый старт

### 1. Базовая настройка

```bash
# Клонирование проекта
git clone <repository-url>
cd whisperx-compose

# Копирование примера конфигурации
cp env.example .env

# Редактирование токена Hugging Face
nano .env
```

### 2. Первый запуск

```bash
# Поместите тестовый аудиофайл
cp ~/audio/test.wav ./audio_input/

# Запуск обработки
docker-compose up

# Просмотр результатов
ls -la audio_output/
cat audio_output/test.json
```

## Конфигурации для разных сценариев

### Быстрая обработка (низкое качество)

```bash
# .env
WHISPER_MODEL_SIZE=tiny
COMPUTE_TYPE=int8
BATCH_SIZE=32
```

### Высокое качество (медленно)

```bash
# .env
WHISPER_MODEL_SIZE=large-v3
COMPUTE_TYPE=float32
BATCH_SIZE=8
```

### Экономия памяти GPU

```bash
# .env
WHISPER_MODEL_SIZE=small
COMPUTE_TYPE=int8
BATCH_SIZE=4
```

## Примеры команд

### Мониторинг процесса

```bash
# Отслеживание логов в реальном времени
docker-compose logs -f whisperx

# Мониторинг использования GPU
watch -n 1 nvidia-smi

# Проверка статуса контейнера
docker ps
```

### Обработка больших файлов

```bash
# Для файлов > 1GB рекомендуется
echo "BATCH_SIZE=4" >> .env
echo "COMPUTE_TYPE=int8" >> .env

# Перезапуск с новыми настройками
docker-compose down
docker-compose up
```

### Пакетная обработка

```bash
# Копирование нескольких файлов
cp ~/recordings/*.wav ./audio_input/

# Запуск обработки всех файлов
docker-compose up

# Архивирование результатов
tar -czf results_$(date +%Y%m%d).tar.gz audio_output/
```

## Анализ результатов

### Просмотр JSON результатов

```bash
# Красивый вывод JSON
cat audio_output/file.json | jq '.'

# Извлечение только текста
cat audio_output/file.json | jq -r '.segments[].text' | tr '\n' ' '

# Подсчет говорящих
cat audio_output/file.json | jq '.segments[].speaker' | sort | uniq -c
```

### Конвертация в другие форматы

```bash
# Простой текст (все сегменты)
cat audio_output/file.json | jq -r '.segments[] | "\(.start)s - \(.end)s: \(.text)"' > output.txt

# Разделение по говорящим
cat audio_output/file.json | jq -r '.segments[] | "\(.speaker): \(.text)"' > speakers.txt

# SRT субтитры (базовый пример)
cat audio_output/file.json | jq -r '.segments[] | "\(.start) --> \(.end)\n\(.text)\n"' > output.srt
```

## Устранение проблем

### Ошибка нехватки памяти GPU

```bash
# Проверка доступной памяти
nvidia-smi

# Очистка кэша GPU
docker-compose down
docker system prune -f

# Уменьшение параметров
sed -i 's/BATCH_SIZE=16/BATCH_SIZE=4/' .env
sed -i 's/COMPUTE_TYPE=float16/COMPUTE_TYPE=int8/' .env
```

### Проблемы с токеном Hugging Face

```bash
# Проверка токена
grep HF_TOKEN .env

# Тест доступа к моделям
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://huggingface.co/api/models/pyannote/speaker-diarization-3.1
```

### Отладка контейнера

```bash
# Вход в контейнер для отладки
docker-compose run --rm whisperx bash

# Ручная проверка команды
docker-compose run --rm whisperx whisperx --help

# Просмотр логов ошибок
docker-compose logs whisperx 2>&1 | grep -i error
```

## Автоматизация

### Скрипт мониторинга папки

```bash
#!/bin/bash
# watch_folder.sh
while true; do
    if [ "$(ls -A audio_input/)" ]; then
        echo "Найдены новые файлы, запуск обработки..."
        docker-compose up

        # Перемещение обработанных файлов
        mkdir -p audio_processed/$(date +%Y%m%d)
        mv audio_input/* audio_processed/$(date +%Y%m%d)/
    fi
    sleep 60
done
```

### Cron задача

```bash
# Добавление в crontab для ежечасной проверки
# crontab -e
0 * * * * cd /path/to/whisperx-compose && docker-compose up >> /var/log/whisperx.log 2>&1
```

## Оптимизация производительности

### Для коротких файлов (< 5 минут)

```bash
WHISPER_MODEL_SIZE=medium
COMPUTE_TYPE=float16
BATCH_SIZE=32
```

### Для длинных файлов (> 1 час)

```bash
WHISPER_MODEL_SIZE=large
COMPUTE_TYPE=int8
BATCH_SIZE=8
```

### Для множественных коротких файлов

```bash
WHISPER_MODEL_SIZE=small
COMPUTE_TYPE=float16
BATCH_SIZE=16
```

## Интеграция с другими системами

### Webhook уведомления

```bash
# Добавить в конец entrypoint.sh
curl -X POST https://your-webhook.com/notify \
     -H "Content-Type: application/json" \
     -d '{"status": "completed", "files_processed": "'$(ls audio_output/*.json | wc -l)'"}'
```

### Автоматическая загрузка в облако

```bash
# Добавить после обработки
rclone copy audio_output/ remote:whisperx-results/$(date +%Y%m%d)/
```
