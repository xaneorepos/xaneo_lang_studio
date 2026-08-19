# Xaneo Lang Studio

<div align="center">

### **Официальная студия создания и настройки языковых пакетов для экосистемы Xaneo**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platforms-Linux%20%7C%20Windows%20%7C%20macOS-blue?style=for-the-badge&logo=linux)](https://github.com/xaneorepos)

</div>

---

## 📌 О проекте

**Xaneo Lang Studio** — это специализированное кроссплатформенное приложение на **Flutter** и **Dart**, предназначенное для создания, редактирования, валидации и экспорта пользовательских языковых пакетов (`.json`, `.xlang`) для всей экосистемы **Xaneo** (Desktop, Web, Mobile).

Интерфейс выполнен в премиальном монохромном стиле (Black & White OLED Design) с высокой контрастностью и эргономикой для комфортной локализации сотен строк интерфейса.

---

## 🌟 Основные возможности

- 📝 **Интерактивный редактор локализации**:
  - Полная поддержка официального канонического манифеста Xaneo v1 (`manifest.v1.json`).
  - Карточки строк с отображением ключа, области видимости (scope), описания и эталонного текста (RU).
  - Быстрая вставка плейсхолдеров (`{0}`, `{count}`, `{username}`) в один клик.
  - Копирование ключа и подстановка эталонного текста в поле перевода в один клик.

- 🗂 **Модульная организация и навигация**:
  - Группировка строк по функциональным модулям (`messenger`, `settings`, `profile`, `auth`, `media`, `calls` и др.).
  - Мгновенный полнотекстовый поиск по ключам, эталонному тексту и переводам.
  - Фильтрация «Только непереведённые» для быстрой доработки неполных пакетов.
  - Счётчики строк и динамический прогресс-бар готовности пакета в реальном времени.

- 🛡 **Встроенный валидатор пакетов**:
  - Контроль стандарта BCP 47 для кода языка (`locale`).
  - Проверка перевода обязательных критически важных строк безопасности (`security_critical`).
  - Проверка сохранения всех плейсхолдеров и непревышения максимальной длины (`max_length`).

- 🔄 **Импорт и Экспорт**:
  - Открытие и редактирование существующих файлов языковых пакетов (`.json`, `.xlang`).
  - Экспорт в стандартизированный JSON-пакет, готовый к установке в клиенты Xaneo.
  - Функция умного автозаполнения недостающих ключей эталонным текстом (RU fallback).

- 🎨 **Монохромный дизайн (OLED B&W)**:
  - Глубокий чёрный фон `#000000`, контрастные карточки, шрифты `Inter` и моноширинный `JetBrains Mono`.

---

## 🛠 Технологический стек

### Core & Framework
| Технология | Описание |
| :--- | :--- |
| **Flutter 3.x** | Кроссплатформенный UI фреймворк |
| **Dart SDK ^3.12.0** | Основной язык разработки |
| **Google Fonts** | Типографика (`Inter`, `JetBrains Mono`) |

### Файлы и Утилиты (Files & Utilities)
| Технология | Описание |
| :--- | :--- |
| **File Picker** | Нативный выбор и сохранение файлов локализации |
| **Path Provider** | Работа с временными и системными путями ОС |
| **Intl** | Форматирование дат и чисел |
| **Archive** | Работа с упакованными архивами пакетов |

---

## 🚀 Запуск и Сборка

### Требования
- Flutter SDK (3.x+)
- Dart SDK (^3.12.0)
- CMake, Ninja, C++ compiler (для сборки desktop-приложений)

### Запуск в режиме разработки

```bash
# Установка зависимостей
flutter pub get

# Запуск на Linux
flutter run -d linux

# Запуск на Windows
flutter run -d windows

# Запуск на macOS
flutter run -d macos
```

### Запуск тестов

```bash
flutter test
```

### Сборка релизных пакетов

```bash
flutter build linux --release
flutter build windows --release
flutter build macos --release
```

---

## 📋 Структура языкового пакета

Экспортируемый файл языкового пакета формируется в формате JSON:

```json
{
  "schema_version": 1,
  "locale": "ru-custom",
  "name": "Custom Language",
  "native_name": "Кастомный язык",
  "direction": "ltr",
  "fallback_locale": "ru",
  "author": "Xaneo Community",
  "version": "1.0.0",
  "description": "Описание языкового пакета",
  "strings": {
    "header.home": "Главная",
    "messenger.chats": "Чаты",
    "messenger.input.message": "Написать сообщение..."
  }
}
```

---

## 📄 Лицензия

Проект распространяется под лицензией **MIT License**. Подробнее см. в файле [LICENSE](LICENSE).

<div align="center">
  <sub>Created with ❤️ by <a href="https://github.com/xaneorepos">Xaneo Repos</a></sub>
</div>
