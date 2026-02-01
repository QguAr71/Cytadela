#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Russian Translations (RU)                                   ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Wizard titles
export T_WIZARD_TITLE="ИНТЕРАКТИВНЫЙ МАСТЕР УСТАНОВКИ"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Мастер Установки"

# Dialog messages
export T_SELECT_MODULES="Выберите модули для установки:"
export T_DIALOG_HELP="(ПРОБЕЛ для переключения, TAB для навигации, ENTER для подтверждения)"
export T_REQUIRED_NOTE="Обязательные модули предварительно выбраны и не могут быть отключены."

# Module descriptions
export T_MOD_DNSCRYPT="Зашифрованный DNS-резолвер (DNSCrypt/DoH)"
export T_MOD_COREDNS="Локальный DNS-сервер с adblock + кэш"
export T_MOD_NFTABLES="Правила брандмауэра (защита от утечек DNS)"
export T_MOD_HEALTH="Автоматический перезапуск служб при сбое"
export T_MOD_SUPPLY="Проверка бинарных файлов (контрольные суммы)"
export T_MOD_LKG="Кэш блок-листа Last Known Good"
export T_MOD_IPV6="Управление расширениями конфиденциальности IPv6"
export T_MOD_LOCATION="Брандмауэр на основе SSID"
export T_MOD_DEBUG="Цепочка отладки NFTables с логированием"

# Summary section
export T_SUMMARY_TITLE="СВОДКА УСТАНОВКИ"
export T_SELECTED_MODULES="Выбранные модули:"
export T_CONFIRM_WARNING="Это установит и настроит DNS-службы в вашей системе."
export T_CONFIRM_PROMPT="Продолжить установку? [y/N]: "

# Installation section
export T_INSTALLING_TITLE="УСТАНОВКА МОДУЛЕЙ"
export T_INSTALLING="Установка"
export T_INSTALLED="установлен"
export T_FAILED="установка не удалась"
export T_INITIALIZED="инициализирован"
export T_INIT_FAILED="инициализация не удалась"
export T_CACHE_SAVED="кэш сохранен"
export T_CACHE_NOT_SAVED="кэш не сохранен (будет создан при первом обновлении)"
export T_CONFIGURED="настроен"
export T_CONFIG_SKIPPED="настройка пропущена"
export T_MODULE_LOADED="модуль загружен"
export T_USE_COMMAND="используйте"
export T_TO_ENABLE="для включения"

# Completion section
export T_COMPLETE_TITLE="УСТАНОВКА ЗАВЕРШЕНА"
export T_ALL_SUCCESS="Все модули успешно установлены!"
export T_SOME_FAILED="модуль(и) не удалось установить"
export T_NEXT_STEPS="Следующие шаги:"
export T_STEP_TEST="Тест DNS: dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="Настроить систему: sudo cytadela++ configure-system"
export T_STEP_VERIFY="Проверить: sudo cytadela++ verify"

# Error messages
export T_CANCELLED="Установка отменена пользователем"
export T_CANCELLED_SHORT="Установка отменена"
export T_UNKNOWN_MODULE="Неизвестный модуль"

# Advanced features (v3.2+)
export T_HONEYPOT_ENABLED="Honeypot включен"
export T_REPUTATION_ACTIVE="Система репутации активна"
export T_ASN_BLOCKING_CONFIGURED="Блокировка ASN настроена"
