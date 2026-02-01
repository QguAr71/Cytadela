#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Spanish Translations (ES)                                   ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Wizard titles
export T_WIZARD_TITLE="ASISTENTE DE INSTALACIÓN INTERACTIVO"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Asistente de Instalación"

# Dialog messages
export T_SELECT_MODULES="Seleccione los módulos a instalar:"
export T_DIALOG_HELP="(ESPACIO para alternar, TAB para navegar, ENTER para confirmar)"
export T_REQUIRED_NOTE="Los módulos requeridos están preseleccionados y no se pueden desactivar."

# Module descriptions
export T_MOD_DNSCRYPT="Resolvedor DNS cifrado (DNSCrypt/DoH)"
export T_MOD_COREDNS="Servidor DNS local con adblock + caché"
export T_MOD_NFTABLES="Reglas de firewall (prevención de fugas DNS)"
export T_MOD_HEALTH="Reinicio automático de servicios en caso de fallo"
export T_MOD_SUPPLY="Verificación de binarios (sumas de verificación)"
export T_MOD_LKG="Caché de lista de bloqueo Last Known Good"
export T_MOD_IPV6="Gestión de extensiones de privacidad IPv6"
export T_MOD_LOCATION="Asesoramiento de firewall basado en SSID"
export T_MOD_DEBUG="Cadena de depuración NFTables con registro"

# Summary section
export T_SUMMARY_TITLE="RESUMEN DE INSTALACIÓN"
export T_SELECTED_MODULES="Módulos seleccionados:"
export T_CONFIRM_WARNING="Esto instalará y configurará los servicios DNS en su sistema."
export T_CONFIRM_PROMPT="¿Continuar con la instalación? [s/N]: "

# Installation section
export T_INSTALLING_TITLE="INSTALANDO MÓDULOS"
export T_INSTALLING="Instalando"
export T_INSTALLED="instalado"
export T_FAILED="instalación fallida"
export T_INITIALIZED="inicializado"
export T_INIT_FAILED="inicialización fallida"
export T_CACHE_SAVED="caché guardado"
export T_CACHE_NOT_SAVED="caché no guardado (se creará en la primera actualización)"
export T_CONFIGURED="configurado"
export T_CONFIG_SKIPPED="configuración omitida"
export T_MODULE_LOADED="módulo cargado"
export T_USE_COMMAND="usar"
export T_TO_ENABLE="para activar"

# Completion section
export T_COMPLETE_TITLE="INSTALACIÓN COMPLETADA"
export T_ALL_SUCCESS="¡Todos los módulos instalados correctamente!"
export T_SOME_FAILED="módulo(s) no se pudieron instalar"
export T_NEXT_STEPS="Próximos pasos:"
export T_STEP_TEST="Probar DNS: dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="Configurar sistema: sudo cytadela++ configure-system"
export T_STEP_VERIFY="Verificar: sudo cytadela++ verify"

# Error messages
export T_CANCELLED="Instalación cancelada por el usuario"
export T_CANCELLED_SHORT="Instalación cancelada"
export T_UNKNOWN_MODULE="Módulo desconocido"

# Advanced features (v3.2+)
export T_HONEYPOT_ENABLED="Honeypot activado"
export T_REPUTATION_ACTIVE="Sistema de reputación activo"
export T_ASN_BLOCKING_CONFIGURED="Bloqueo ASN configurado"
