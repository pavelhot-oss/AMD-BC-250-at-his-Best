#!/usr/bin/env bash
# locale/ru.sh — Russian message catalog for bc250-beast. Sourced by
# lib/i18n.sh on top of locale/en.sh (any key missing here falls back to
# English).
#
# Machine-drafted translation: needs review by a native speaker.
#
# Rules (same as en.sh):
#   - one   MSG[key]="..."   per message, keys are [a-z0-9_]
#   - values are printf formats: %s = argument, %% = literal percent sign
#   - keep argument ORDER identical in every language (bash printf has no
#     positional %1$s), and keep the same number of placeholders
#   - multi-line messages are fine, just keep the closing quote on the last line
#   - escape " as \" and $ as \$
# Validate with: tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / language selection
# ------------------------------------------------------------------
MSG[lang_name]="Русский"
MSG[i18n_invalid]="Неизвестный язык: %s (доступны: %s)"
MSG[i18n_switched]="Язык: %s (%s)"
MSG[i18n_save_q]="Сохранить этот выбор в файле конфигурации (%s)?"
MSG[i18n_saved]="Язык сохранён в конфигурации: %s"
MSG[i18n_save_failed]="Не удалось сохранить язык (файл конфигурации не найден: %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="Продолжить?"
MSG[common_yn]="[y/N]"
MSG[common_yes_regex]="^[YyДд]$"
MSG[common_continue_anyway_q]="Всё равно продолжить?"
MSG[common_empty]="<пусто>"
MSG[common_need_root]="Этот модуль нужно запускать от root (sudo)."
MSG[common_hw_check_skipped]="Проверка оборудования пропущена (--force)."
MSG[common_no_bc250]="AMD BC-250 не обнаружен (PCI 1002:13fe не найден). Используйте --force, чтобы обойти эту защиту."
MSG[common_bc250_found]="Обнаружен AMD BC-250 (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live завершился ошибкой, выполняется обычная установка (после неё потребуется перезагрузка)"
MSG[common_steamos_unsupported]="Иммутабельная SteamOS не поддерживается — руководство рекомендует Bazzite."
MSG[common_unknown_distro_pkg]="Дистрибутив не распознан, установите вручную: %s"
MSG[common_reboot_needed]="Для применения изменений выше требуется перезагрузка."
MSG[common_reboot_now_q]="Перезагрузить сейчас?"
MSG[common_reboot_reminder]="Не забудьте перезагрузиться, прежде чем переходить к следующим модулям."
MSG[common_config_created]="Конфигурация не найдена, пример скопирован в %s (подстройте его под вашу плату)."
MSG[common_config_missing]="Файл конфигурации не найден: %s"
MSG[common_banner_tagline]="AMD BC-250 -> Steam Machine на полную мощность"
MSG[common_m01_not_confirmed]="Модуль 01 (охлаждение/питание) не был подтверждён."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh — единая точка входа bc250-beast.

Превращает AMD BC-250 в \"зверя\", запуская в порядке, рекомендованном
сообществом (сводка Old Lamer, docs/guide_old_lamer.md), встроенные
инструменты (bc250-core-unlock, bc250-cu-live-manager, bc250-40cu-unlock,
bc250_smu_oc, UEFI BIOS Forbidden-Darkness) и несколько системных
настроек (zswap, mitigations, MangoHud).

Использование:
  sudo ./install.sh                 # интерактивное меню
  sudo ./install.sh --all           # запустить все модули по порядку
  sudo ./install.sh --module 05     # запустить только модуль 05
  sudo ./install.sh --status        # быстрая диагностика текущего состояния
  sudo ./install.sh --lang ru       # язык интерфейса, один код на файл
                                    # в locale/ (также BC250_LANG или UI_LANG
                                    # в конфигурации)
  sudo ./install.sh --all --yes     # без подтверждений (берёт значения из
                                    # конфигурации, не спрашивая на каждом
                                    # шаге — только для повторного
                                    # развёртывания уже проверенной вручную
                                    # конфигурации)
  sudo ./install.sh --force ...     # пропустить определение BC-250 по PCI
                                    # (для dev / CI без реального железа)"

MSG[mod_00_desc]="Предварительные проверки (железо, дистрибутив, зависимости)"
MSG[mod_01_desc]="Охлаждение и питание (физический чеклист)"
MSG[mod_02_desc]="Модифицированный BIOS/UEFI (8 ядер встроено + 512 МБ VRAM)"
MSG[mod_03_desc]="Разблокировка 8 ядер CPU (программная, с сохранением)"
MSG[mod_04_desc]="Разблокировка Compute Unit GPU (до 40 CU)"
MSG[mod_05_desc]="Разгон/андервольт CPU (SMU)"
MSG[mod_06_desc]="Разгон GPU (регулятор cyan-skillfish)"
MSG[mod_07_desc]="Настройка системы (zswap, mitigations, MangoHud)"
MSG[mod_08_desc]="Дополнительно (корпуса, NullVRS, ссылки сообщества)"
MSG[mod_09_desc]="Проверка и бенчмарк"

MSG[inst_module_not_found]="Модуль не найден: %s"
MSG[inst_module_failed]="Модуль %s завершился с ошибкой (код выхода %s). Последовательность остановлена — устраните проблему и запустите снова с --module %s."
MSG[inst_status_title]="Текущее состояние"
MSG[inst_status_bc250_yes]="Обнаружен AMD BC-250."
MSG[inst_status_bc250_no]="AMD BC-250 в этой системе не обнаружен."
MSG[inst_status_distro]="Дистрибутив: %s"
MSG[inst_status_threads]="Потоки CPU    : %s"
MSG[inst_status_mitig_off]="Mitigations   : отключены"
MSG[inst_status_mitig_on]="Mitigations   : включены (по умолчанию)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Активный swap : да"
MSG[inst_status_swap_no]="Активный swap : нет"
MSG[inst_status_unlock_svc]="Разблок. 8 ядер (служба) : включена"
MSG[inst_status_oc_svc]="Разгон CPU (служба)      : включена"
MSG[inst_status_umr_yes]="umr           : установлен"
MSG[inst_status_umr_no]="umr           : отсутствует"
MSG[inst_status_gpu_hint]="Подробности по GPU (таблица WGP / активные CU):"
MSG[inst_menu_config]="Конфигурация  : %s"
MSG[inst_menu_lang]="Язык          : %s"
MSG[inst_menu_all]="a) Выполнить всё в рекомендованном порядке"
MSG[inst_menu_status]="s) Состояние / диагностика"
MSG[inst_menu_edit]="e) Редактировать конфигурацию (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Язык / Language"
MSG[inst_menu_quit]="q) Выход"
MSG[inst_prompt_choice]="Выбор: "
MSG[inst_press_enter]="Нажмите Enter для продолжения..."
MSG[inst_done_press_enter]="Готово. Нажмите Enter для продолжения..."
MSG[inst_invalid_choice]="Неверный выбор."
MSG[inst_unknown_arg]="Неизвестный аргумент: %s (см. --help)"
MSG[inst_module_needs_id]="--module требует идентификатор (например, 05-cpu-overclock или 05)"
MSG[inst_no_module_number]="Нет модуля с номером %s"
MSG[inst_lang_needs_arg]="--lang требует код языка (доступны: %s)"
MSG[inst_final_validation_q]="Запустить финальную проверку (модуль 09)?"
MSG[inst_yes_mode_validation]="Режим --yes: финальная проверка запускается автоматически."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh — удаляет ПОСТОЯННЫЕ изменения, установленные bc250-beast.
Не трогает прошитый BIOS (модуль 02) и охлаждение/проводку (модуль 01).

Использование:
  sudo ./uninstall.sh [--lang <код>]"
MSG[uninst_title]="Удаление постоянных изменений bc250-beast"
MSG[uninst_rm_core_unlock]="Удаление службы bc250-core-unlock..."
MSG[uninst_disable_smu_oc]="Отключение службы bc250-smu-oc (настройка разгона CPU)..."
MSG[uninst_gpu_stock]="Восстановление заводской таблицы WGP (24 CU) и удаление службы автозапуска..."
MSG[uninst_rm_file]="Удаление %s"
MSG[uninst_kargs]="Удаление добавленных параметров ядра (zswap, mitigations)..."
MSG[uninst_kargs_reboot]="Чтобы удаление параметров ядра вступило в силу, требуется перезагрузка."
MSG[uninst_swap_kept_1]="Btrfs-swapfile (/var/swap) и его строка в fstab НЕ были удалены"
MSG[uninst_swap_kept_2]="автоматически (деструктивная операция). При желании удалите их вручную:"
MSG[uninst_done_1]="Удаление завершено. Прошитый BIOS (модуль 02) и проводка"
MSG[uninst_done_2]="(модуль 01) остаются на месте — это аппаратные изменения."

# ------------------------------------------------------------------
# Module 00 — preflight
# ------------------------------------------------------------------
MSG[m00_title]="00 - Предварительные проверки"
MSG[m00_q_test_boot]="Вы сделали тестовый запуск (БП + клавиатура + DisplayPort) и убедились, что BIOS доступен, прежде чем продолжать?"
MSG[m00_dry_test_boot]="[DRY-RUN] Вопрос о тестовом запуске: %s"
MSG[m00_strongly_recommended]="Настоятельно рекомендуется перед любыми изменениями."
MSG[m00_abort_user]="Остановлено по запросу пользователя. Сделайте тестовый запуск и запустите снова."
MSG[m00_distro_detected]="Обнаружен дистрибутив: %s"
MSG[m00_distro_unknown]="Дистрибутив не распознан автоматически. Модули могут завершаться ошибкой на шагах установки пакетов."
MSG[m00_kernel]="Ядро  : %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Отсутствуют инструменты: %s"
MSG[m00_install_deps_q]="Установить базовые зависимости сейчас?"
MSG[m00_deps_ok]="Все базовые зависимости присутствуют."
MSG[m00_done]="Предварительные проверки завершены."

# ------------------------------------------------------------------
# Module 01 — cooling & power
# ------------------------------------------------------------------
MSG[m01_title]="01 - Охлаждение и питание (физические шаги)"
MSG[m01_checklist]="Этот модуль ничего не меняет на машине: охлаждение и питание —
аппаратные шаги, которые нужно выполнить ДО программного разгона
(модули 05/06), иначе вы рискуете получить сбои, троттлинг или даже
повреждение железа.

Чеклист (подробности в docs/guide_old_lamer.md, разделы 2 и 3):

  [ ] Охлаждение выбрано и установлено:
        - СЖО 240 мм (лучший вариант, <60°C под нагрузкой)
        - или 1x вентилятор 120 мм (например, Arctic P12 Pro) на частично
          вскрытом радиаторе (вырезать ТОЛЬКО область под вентилятор)
  [ ] Термопаста на APU заменена: PTM 7950 (выигрыш 5-8°C)
  [ ] Термозамазка (thermal putty) нанесена на VRM + чипы GDDR
  [ ] Пассивный радиатор приклеен на бэкплейт (область RAM/VRAM)
  [ ] Пластиковые шайбы подложены под пружинные винты центрального
        радиатора (прижим PTM 7950).
  [ ] Если б/у вентилятор без PWM: никогда не ниже 1800 RPM.
  [ ] БП подобран правильно: не менее 25 А по линии 12 В
        (FSP500 / Meanwell 500 Вт / Meanwell LOP-300-12 / серверный БП
        Dell-HP с проверенной распиновкой)
  [ ] Если плата разблокирована до 40 CU + сильно разогнана (>300 Вт):
        2x разъёма Molex Microfit 3.0 (43025-0800) добавлены в дополнение
        к штатному разъёму PCIe, провода не тоньше AWG18

⚠️  Единственный штатный разъём PCIe может РАСПЛАВИТЬСЯ под большой
    нагрузкой (40 CU разблокированы + разгон). Не поднимайте разгон GPU
    (модуль 06) без этого шага, если целитесь выше ~250-300 Вт.
"
MSG[m01_confirm_q]="Вы подтверждаете, что охлаждение и питание установлены и проверены?"
MSG[m01_confirmed]="Физический шаг подтверждён пользователем. Можно продолжать."
MSG[m01_not_confirmed]="Шаг не подтверждён. Настоятельно рекомендуется выполнить его, прежде чем переходить к разгону (модули 05/06)."

# ------------------------------------------------------------------
# Module 02 — BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - Модифицированный BIOS/UEFI (8 ядер встроено + 512 МБ VRAM)"
MSG[m02_intro]="Этот шаг прошивает модифицированный BIOS (Forbidden-Darkness UEFI Menu
Script), который:
  - встраивает разблокировку 8 ядер CPU прямо в меню BIOS
    (постоянно, не нужно запускать скрипт после каждого холодного старта)
  - позволяет изменить выделение VRAM с 8 ГБ (по умолчанию) на 512 МБ,
    что необходимо для динамического распределения RAM/VRAM в играх

Процедура (кратко — визуальные детали смотрите в официальном видео
проекта, ссылка в docs/guide_old_lamer.md, раздел 4):

  1. Понадобится отформатированная USB-флешка.
  2. Этот скрипт копирует reboot-uefi.sh + архив Firmware.7z на флешку.
  3. Вы запустите reboot-uefi.sh с опцией 4 (распаковать .7z на флешку),
     затем с опцией 2 (однократная перезагрузка с флешки через efibootmgr).
  4. В оболочке UEFI: fs1: -> запустить утилиту прошивки из архива
     -> сохранить старый BIOS (префикс -O) -> прошить новый (-P -N).
  5. Сбросить CMOS (перемычка или снять батарейку на 20-30 с).
  6. В новом BIOS: включить \"Unlock CPU cores\" и вернуть VRAM на
     512 МБ (значение задаётся в конфигурации: BIOS_TARGET_VRAM_MB).

⚠️  Неудачная прошивка BIOS может вывести плату из строя. Следуйте
    процедуре буквально и сохраните резервную копию старого BIOS."
MSG[m02_no_removable]="Съёмные носители не обнаружены."
MSG[m02_yes_mode_skip_1]="BC250_YES=1: прошивка BIOS — физический шаг (перезагрузка в оболочку UEFI + ручные"
MSG[m02_yes_mode_skip_2]="действия), который нельзя сделать неинтерактивным. Копирование на USB-флешку пропущено."
MSG[m02_usb_prompt]="Точка монтирования целевой USB-флешки (например, /run/media/\$USER/USBSTICK), пусто — пропустить: "
MSG[m02_copying]="Копирование reboot-uefi.sh и Firmware.7z в %s ..."
MSG[m02_copied]="Файлы скопированы. Затем запустите, С USB-ФЛЕШКИ:"
MSG[m02_copy_skipped]="Копирование пропущено. Можно запустить вручную:"
MSG[m02_yes_mode_tool_1]="BC250_YES=1: reboot-uefi.sh — интерактивная утилита (меню, запросы) — не запускается автоматически."
MSG[m02_yes_mode_tool_2]="Запустите её сами: sudo bash '%s'"
MSG[m02_run_tool_q]="Запустить интерактивную утилиту reboot-uefi.sh сейчас (пункты меню 4, затем 2)?"
MSG[m02_reminder_1]="Напоминание: после прошивки + сброса CMOS зайдите в BIOS, включите"
MSG[m02_reminder_2]="\"Unlock CPU cores\" и установите VRAM на %s МБ, прежде чем продолжать."
MSG[m02_flashed_q]="Прошивка BIOS выполнена и опция 'Unlock CPU cores' включена в BIOS?"
MSG[m02_flag_created]="Флаг bios_flashed.flag создан — модуль 03 обнаружит модифицированный BIOS."
MSG[m02_flag_not_created]="Флаг не создан. Модуль 03 попробует программную разблокировку (не сохраняется)."

# ------------------------------------------------------------------
# Module 03 — CPU core unlock
# ------------------------------------------------------------------
MSG[m03_title]="03 - Разблокировка 8 ядер CPU"
MSG[m03_bios_detected_1]="Обнаружен модифицированный BIOS. Разблокировка 8 ядер выполняется самим BIOS."
MSG[m03_bios_detected_2]="Не забудьте проверить, что опция 'Unlock CPU cores' включена в меню BIOS."
MSG[m03_stop_governor]="Временная остановка cyan-skillfish-governor-smu (нужна для записи в SMU)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 в конфигурации, модуль пропущен."
MSG[m03_attempt]="Попытка разблокировать ядра CPU..."
MSG[m03_mask_written]="Маска присутствия ядер CPU успешно записана."
MSG[m03_unlock_failed_1]="Разблокировка не удалась. См. вывод выше. Нестандартная маска (≠0x77)"
MSG[m03_unlock_failed_2]="указывает на реальный дефект кристалла: перечитайте modules/03-cpu-core-unlock, прежде чем форсировать."
MSG[m03_install_service_q]="Установить службу systemd для сохранения (применяется при каждой загрузке)?"
MSG[m03_service_installed]="Служба bc250-core-unlock.service установлена и включена."
MSG[m03_takes_effect_after_reboot]="Разблокировка вступает в силу ПОСЛЕ перезагрузки (запись в SMU включает ядра только при следующей загрузке)."
MSG[m03_no_persistence]="Сохранение не установлено: запускайте этот модуль после каждого полного отключения питания."
MSG[m03_reboot_q]="Перезагрузить сейчас, чтобы включить 8 ядер?"

# ------------------------------------------------------------------
# Module 04 — GPU CU unlock
# ------------------------------------------------------------------
MSG[m04_title]="04 - Разблокировка Compute Unit (CU) GPU"
MSG[m04_umr_missing]="umr не найден, установка через встроенную утилиту..."
MSG[m04_immutable_reboot]="Иммутабельная система (rpm-ostree): перед продолжением требуется перезагрузка."
MSG[m04_rerun_after_reboot]="Запустите этот модуль снова после перезагрузки."
MSG[m04_current_table]="Текущая таблица WGP:"
MSG[m04_mode_full]="Режим в конфигурации: FULL -> разблокировка всех 40 CU (20 WGP)."
MSG[m04_mode_factory]="Режим в конфигурации: FACTORY -> восстановление заводской таблицы (24 CU)."
MSG[m04_mode_custom]="Режим в конфигурации: CUSTOM -> полная разблокировка, затем маскирование перечисленных WGP."
MSG[m04_disable_wgp]="Отключение дефектного WGP: %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom, но GPU_CU_DISABLE_LIST пуст, маскировать нечего."
MSG[m04_unknown_mode]="Неизвестный GPU_CU_MODE в конфигурации: %s (ожидается: full|factory|custom)"
MSG[m04_new_table]="Новая таблица WGP:"
MSG[m04_test_stability]="Проверьте стабильность сейчас (FurMark Vulkan + игра), ПРЕЖДЕ чем делать эту настройку постоянной."
MSG[m04_make_permanent_q]="Конфигурация стабильна, сделать её постоянной при загрузке (write-service-table + install-service)?"
MSG[m04_permanent_done]="Таблица сохранена, служба восстановления при загрузке установлена."
MSG[m04_live_only]="Настройка применена только ВЖИВУЮ: она будет потеряна при следующей перезагрузке."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Альтернативный метод \"патченное ядро\" (vendor/bc250-40cu-unlock):
  полезен, если ваша harvest map НЕ симметрична (отключённые пары
  разбросаны, а не находятся все с одной стороны). См.:
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Этот модуль (live manager) остаётся рекомендуемым первым методом.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Module 05 — CPU overclock
# ------------------------------------------------------------------
MSG[m05_title]="05 - Разгон / андервольт CPU"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s превышает абсолютный предел безопасности 1300 мВ. Исправьте config/bc250-beast.conf."
MSG[m05_install_stress]="Установка утилиты стресс-теста 'stress-ng'..."
MSG[m05_install_smu_oc]="Установка bc250-smu-oc из встроенной копии..."
MSG[m05_apply_q]="Применить %s МГц @ %s мВ сейчас?"
MSG[m05_applying]="Применение разгона С сохранением (--keep): %s МГц @ %s мВ (предел температуры %s°C)"
MSG[m05_threads_warn_1]="Видно %s потоков (ожидается 16 после разблокировки 8 ядер) — вы"
MSG[m05_threads_warn_2]="перезагружались после модуля 03? Стресс-тест всё равно будет использовать %s потоков."
MSG[m05_stress_start]="Стресс-тест CPU на %s с (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Стресс-тест провален — возврат к стоковым значениям."
MSG[m05_reverted]="Возвращены стоковые значения."
MSG[m05_stable_q]="Система осталась стабильной, сделать эту настройку постоянной при загрузке?"
MSG[m05_service_enabled]="Служба bc250-smu-oc включена при загрузке с %s МГц @ %s мВ."
MSG[m05_not_permanent]="Настройка не сделана постоянной — возврат к стоковым значениям."
MSG[m05_monitoring_tip]="
Советы по мониторингу:
  - amdgpu_top (метрики SMU в реальном времени)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (заметить clock stretching)"

# ------------------------------------------------------------------
# Module 06 — GPU governor
# ------------------------------------------------------------------
MSG[m06_title]="06 - Разгон GPU (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Отсутствуют зависимости для сборки:"
MSG[m06_install_with]="Установите командой:"
MSG[m06_arch_libudev_note]="  # libudev на Arch/CachyOS предоставляется systemd, отдельного пакета нет"
MSG[m06_ostree_build_env]="Окружение для сборки будет доступно после перезагрузки (иммутабельная система rpm-ostree)"
MSG[m06_unknown_distro_deps]="Дистрибутив не распознан (%s). Установите вручную: git, make, cargo, pkg-config, заголовки libudev."
MSG[m06_deps_ok]="Все зависимости для сборки присутствуют."
MSG[m06_cloning]="Клонирование cyan-skillfish-governor (ветка smu)..."
MSG[m06_repo_update]="Репозиторий уже присутствует, обновление..."
MSG[m06_pull_failed]="Pull не удался, продолжаем с существующей локальной копией."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release в %s"
MSG[m06_building]="Сборка регулятора (cargo build --release)..."
MSG[m06_build_failed]="cargo build завершился ошибкой. Проверьте ошибки выше."
MSG[m06_build_ok]="Сборка успешна. Бинарный файл: %s"
MSG[m06_follow_readme]="
⚠️  Бинарный файл собран. Точную процедуру установки (служба systemd,
    пути) смотрите в README репозитория — она может меняться со временем:
        %s/README.md
    Когда бинарный файл/служба будут установлены средствами самого
    репозитория, возвращайтесь сюда для настройки.
"
MSG[m06_installed_q]="Регулятор установлен (бинарный файл + служба systemd на месте)? Перейти к настройке?"
MSG[m06_config_postponed]="Настройка отложена. Запустите этот модуль снова после завершения установки регулятора."
MSG[m06_generating]="Генерация %s (кривая idle -> цель, целевая температура %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] Запись %s:"
MSG[m06_toml_header]="# Сгенерировано bc250-beast — модуль 06
# Значения по умолчанию из upstream могут быть нестабильны: проверьте
# вручную, прежде чем включать при загрузке."
MSG[m06_toml_no_volt]="# напряжение не задано в конфигурации -> проверьте значение регулятора по умолчанию"
MSG[m06_file_written]="Файл записан: %s"
MSG[m06_progression]="
Прогрессия, рекомендованная Old Lamer:
  1500 МГц (сток) -> 2000 МГц (лёгкий шаг, ~10%%+ в FurMark)
  -> проверить CPU на 3.85 ГГц (модуль 05) -> поднимать GPU дальше
  ТОЛЬКО если охлаждение справляется (СЖО: сообщают о ~2.4 ГГц,
  ~360 Вт / 30 А, отсюда важность дополнительных разъёмов Molex
  из модуля 01).

⚠️  ВАЖНО: проверьте этот файл конфигурации ВРУЧНУЮ (запустите службу
    на переднем плане / вручную), прежде чем включать при загрузке.
    НЕ включайте службу автоматически из этого скрипта."
MSG[m06_restart_q]="Перезапустить службу регулятора сейчас, чтобы применить проверенную конфигурацию?"
MSG[m06_service_name_hint]="Точное имя службы может отличаться в зависимости от версии репозитория — проверьте: 'systemctl list-units | grep -i cyan'."
MSG[m06_enable_yourself]="Когда стабильность подтверждена вручную, включите автозапуск самостоятельно:"
MSG[m06_upstream_service]="Репозиторий upstream (ветка smu) предоставляет собственную службу systemd."
MSG[m06_see_readme]="Точную процедуру установки см. в %s/README.md."

# ------------------------------------------------------------------
# Module 07 — system tuning
# ------------------------------------------------------------------
MSG[m07_title]="07 - Настройка системы (zswap / mitigations / MangoHud)"
MSG[m07_zswap_ostree]="Включение zswap + mitigations=off через параметры ядра (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] Потребовалась бы перезагрузка (иммутабельная система rpm-ostree)."
MSG[m07_ostree_reboot]="Требуется перезагрузка (иммутабельная система rpm-ostree)."
MSG[m07_rerun_after_reboot]="Запустите этот модуль снова после перезагрузки: он определит, что параметры ядра уже активны."
MSG[m07_var_not_btrfs_1]="/var в этой системе не на Btrfs — официальная процедура (выделенный"
MSG[m07_var_not_btrfs_2]="Btrfs-swapfile) в таком виде не применима. Создайте обычный swapfile вручную"
MSG[m07_var_not_btrfs_3]="или пропустите этот подмодуль, если вы не на Bazzite/Btrfs."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (если существует)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (требуется перезагрузка)"
MSG[m07_dry_final_check]="[DRY-RUN] Финальная проверка: rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
MSG[m07_swapoff]="Отключение существующего swap..."
MSG[m07_rm_old_swap]="Удаление старого /var/swap..."
MSG[m07_create_subvol]="Создание подтома Btrfs /var/swap..."
MSG[m07_selinux_fix]="Исправление контекста SELinux..."
MSG[m07_semanage_missing]="semanage отсутствует, нужно установить policycoreutils-python-utils (rpm-ostree, перезагрузка)."
MSG[m07_rerun_selinux]="Запустите этот подмодуль снова после перезагрузки, чтобы завершить настройку SELinux + создать swapfile."
MSG[m07_create_swapfile]="Создание swapfile размером %sG..."
MSG[m07_fstab]="Добавление в /etc/fstab..."
MSG[m07_swapon]="Немедленное включение swap..."
MSG[m07_swappiness]="Установка vm.swappiness=%s (оптимизация под игры)..."
MSG[m07_final_check]="Финальная проверка:"
MSG[m07_zswap_not_active]="zswap ещё не активен (ожидается перезагрузка?)"
MSG[m07_mangohud_title]="Установка MangoHud (оверлей FPS/температур/загрузки GPU-CPU)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] MangoHud обычно предустановлен на Bazzite. Проверка: command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud предустановлен на SteamOS — установка пропущена"
MSG[m07_mangohud_bazzite_check]="MangoHud обычно предустановлен на Bazzite. Проверка..."
MSG[m07_mangohud_present]="MangoHud уже присутствует."
MSG[m07_mangohud_steamos]="MangoHud предустановлен на SteamOS — установка пропущена"
MSG[m07_mangohud_steam_hint]="Чтобы включить в Steam: добавьте 'mangohud %%command%%' в параметры запуска игры."
MSG[m07_zswap_already]="zswap уже включён на уровне ядра, переходим сразу к созданию swapfile."
MSG[m07_zswap_other_distro_1]="Официальная процедура zswap+swapfile описана только для Bazzite/rpm-ostree+Btrfs."
MSG[m07_zswap_other_distro_2]="На %s: включите zswap через GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="затем перегенерируйте конфигурацию загрузчика (grub-mkconfig / bootctl и т.д., в зависимости от вашей системы) и создайте обычный swapfile."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 в конфигурации, шаг пропущен."
MSG[m07_mitig_title]="Отключение mitigations CPU (защита от Spectre/Meltdown)"
MSG[m07_mitig_warn_1]="Это снижает защиту от некоторых локальных атак (side-channel)."
MSG[m07_mitig_warn_2]="Рекомендуется только на выделенной игровой машине, не на чувствительной рабочей станции общего назначения."
MSG[m07_mitig_confirm_q]="Подтвердить отключение mitigations CPU?"
MSG[m07_mitig_ostree_done]="mitigations=off уже применён через setup_zswap_ostree (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Добавьте 'mitigations=off' в GRUB_CMDLINE_LINUX (или в вашу конфигурацию systemd-boot),"
MSG[m07_mitig_grub_2_dry]="затем перегенерируйте конфигурацию загрузчика (grub-mkconfig / bootctl и т.д.) и перезагрузитесь."
MSG[m07_mitig_grub_2]="затем перегенерируйте конфигурацию загрузчика и перезагрузитесь."
MSG[m07_mitig_done]="Mitigations отключены (вступает в силу после перезагрузки)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (или не задан), шаг пропущен."
MSG[m07_done]="Модуль 07 завершён."

# ------------------------------------------------------------------
# Module 08 — extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Дополнительно"
MSG[m08_intro]="В этом разделе собраны дополнительные возможности, упомянутые в видео
Old Lamer и не обязательные для базовой работы:

  1) Рекомендуемые корпуса для 3D-печати
       - NextGen3D (магазин)  : https://nexgen3d.bigcartel.com/
       - NextGen3D (модели)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro с СЖО 240 мм:
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Вариант с воздушным кулером CPU:
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (слой Vulkan, полезен для некоторых игр вроде Doom: The
     Dark Ages на урезанном GPU): https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling через Decky Loader (Frame Generation)
       - Требует заранее установленного Decky Loader на Bazzite/SteamOS-
         подобных системах (сюда не входит, см. официальный Decky Loader).

  4) USB-экран мониторинга 3.5\" IPS (Turing Smart Screen):
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Сообщества:
       Discord: https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU): https://t.me/BC250public"
MSG[m08_no_home]="Не удалось определить домашний каталог пользователя %s."
MSG[m08_dry_download]="[DRY-RUN] Скачать %s"
MSG[m08_dry_extract]="[DRY-RUN] Распаковать в /tmp/nullvrs и скопировать *.json + *.so в %s"
MSG[m08_downloading]="Скачивание NullVRS 1.0.0..."
MSG[m08_nullvrs_installed]="NullVRS установлен в %s (владелец: %s):"
MSG[m08_files_not_found]="Файлы не найдены, проверьте скачанный архив."
MSG[m08_repo_update]="Репозиторий уже присутствует в %s, обновление..."
MSG[m08_pull_failed]="Pull не удался."
MSG[m08_cloning_turing]="Клонирование turing-smart-screen-python..."
MSG[m08_cloned_in]="Склонировано в:"
MSG[m08_turing_steps]="Следующие шаги (вручную, в зависимости от вашего дистрибутива):
  1) cd %s
  2) Создать виртуальное окружение Python: python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Настроить экран (см. README репозитория: config.yaml, поворот, USB-порт)
  5) Проверить: python main.py
  6) Для службы systemd: скопировать turing-screen.service в /etc/systemd/system/ и поправить пути"
MSG[m08_see_readme]="Полная настройка описана в README репозитория."
MSG[m08_community_title]="Ссылки сообщества BC-250"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="Магазин NextGen3D"
MSG[m08_lbl_models]="Модели на Printables"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="Вариант с воздушным кулером CPU"
MSG[m08_submenu_title]="Подменю «Дополнительно»"
MSG[m08_opt_1]="1) Установить Vulkan NullVRS (v1.0.0)"
MSG[m08_opt_2]="2) Подготовить Turing Smart Screen 3.5\" (клонирование + инструкции)"
MSG[m08_opt_3]="3) Показать ссылки сообщества (отформатированные)"
MSG[m08_opt_q]="q) Назад / Выход"
MSG[m08_prompt]="Выбор [1-3/q]: "
MSG[m08_done]="Модуль 08 завершён."

# ------------------------------------------------------------------
# Module 09 — validation
# ------------------------------------------------------------------
MSG[m09_title]="09 - Проверка и бенчмарк"
MSG[m09_invalid_status]="Недопустимый статус для report_result: %s"
MSG[m09_dry_cmd]="[DRY-RUN] Команда: %s"
MSG[m09_instant_title]="Мгновенные проверки"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Проверка числа ядер CPU (ожидается: 16 потоков / 8 физических ядер)"
MSG[m09_t_cpu_cores_16]="Ядра CPU (16 потоков / 8 ядер)"
MSG[m09_threads_detected]="обнаружено потоков: %s"
MSG[m09_t_cpu_cores_8]="Ядра CPU (8 потоков / 4 ядра)"
MSG[m09_threads_not_unlocked]="потоков: %s — разблокировка 8 ядер не применена (модуль 03)"
MSG[m09_t_cpu_cores]="Ядра CPU"
MSG[m09_threads_unexpected]="потоков: %s — неожиданное значение"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Проверка частоты CPU (конфигурация: %s МГц ±100 МГц)"
MSG[m09_t_cpu_freq_near]="Частота CPU (близка к CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s МГц (цель: %s МГц)"
MSG[m09_t_cpu_freq_diff200]="Частота CPU (отклонение ≤ 200 МГц)"
MSG[m09_t_cpu_freq_diff_gt200]="Частота CPU (отклонение > 200 МГц)"
MSG[m09_freq_target_diff]="%s МГц (цель: %s МГц, отклонение: %s МГц)"
MSG[m09_t_cpu_freq]="Частота CPU"
MSG[m09_cpuinfo_unreadable]="Не удалось прочитать /proc/cpuinfo"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Проверка активных CU GPU через bc250-cu-live-manager (конфигурация: %s)"
MSG[m09_t_gpu_cu_match]="Активные CU GPU (соотв. GPU_CU_MODE)"
MSG[m09_cu_active_expected]="активных CU: %s (ожидается: %s)"
MSG[m09_t_gpu_cu_mismatch]="Активные CU GPU (не соотв. GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="активных CU: %s (ожидается: %s для режима %s)"
MSG[m09_t_gpu_cu]="Активные CU GPU"
MSG[m09_cu_detected_mode]="обнаружено активных CU: %s (режим в конфигурации: %s)"
MSG[m09_cu_parse_fail]="Не удалось разобрать вывод bc250-cu-live-manager"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager не установлен или не исполняемый"
MSG[m09_dry_services]="[DRY-RUN] Проверка служб systemd (bc250-core-unlock, bc250-smu-oc, cyan-skillfish-governor)"
MSG[m09_t_service]="Служба %s"
MSG[m09_svc_active]="активна"
MSG[m09_svc_enabled_inactive]="включена, но не активна (ещё запускается?)"
MSG[m09_svc_inactive]="неактивна / не включена"
MSG[m09_dry_vram]="[DRY-RUN] Проверка выделения VRAM в BIOS (цель: %s МБ)"
MSG[m09_t_vram_target]="VRAM в BIOS (%s МБ)"
MSG[m09_vram_detected]="обнаружено %s МБ"
MSG[m09_t_vram_default]="VRAM в BIOS (8 ГБ = по умолчанию)"
MSG[m09_vram_default_msg]="VRAM 8 ГБ (по умолчанию), переключение на 512 МБ не выполнено (модуль 02)"
MSG[m09_t_vram]="VRAM в BIOS"
MSG[m09_vram_detected_target]="обнаружено %s МБ (цель: %s МБ)"
MSG[m09_vram_unknown]="Не удалось определить выделение VRAM"
MSG[m09_dry_temps]="[DRY-RUN] Проверка температур CPU/GPU через sensors"
MSG[m09_t_cpu_temp_ok]="Температура CPU (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="Температура GPU (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="Температура CPU (> 85°C)"
MSG[m09_t_gpu_temp_high]="Температура GPU (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C — проверьте охлаждение (модуль 01)"
MSG[m09_t_cpu_temp]="Температура CPU"
MSG[m09_t_gpu_temp]="Температура GPU"
MSG[m09_temp_not_detected]="Не определена через sensors"
MSG[m09_t_temps]="Температура CPU/GPU"
MSG[m09_sensors_missing]="Команда 'sensors' недоступна (lm-sensors не установлен)"
MSG[m09_dry_voltage]="[DRY-RUN] Проверка напряжения CPU через bc250_smu_oc или sensors (жёсткий предел: 1300 мВ, допуск ±50 мВ от CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="Напряжение CPU (≤ 1300 мВ, ±50 мВ)"
MSG[m09_t_voltage_danger]="Напряжение CPU (> 1300 мВ = ОПАСНО)"
MSG[m09_voltage_danger_msg]="%s мВ (источник: %s) — ПРЕВЫШАЕТ АБСОЛЮТНЫЙ ПРЕДЕЛ БЕЗОПАСНОСТИ"
MSG[m09_voltage_ok_msg]="%s мВ (цель: %s мВ, источник: %s)"
MSG[m09_t_voltage_diff]="Напряжение CPU (отклонение > 50 мВ)"
MSG[m09_voltage_diff_msg]="%s мВ (цель: %s мВ, отклонение: %s мВ, источник: %s)"
MSG[m09_t_voltage]="Напряжение CPU"
MSG[m09_voltage_unreadable]="Напряжение не читается (bc250_smu_oc, bc250_detect.py, sensors Vcore) — проверьте вручную"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Проверка частоты GPU через /sys/class/drm/card0/device/pp_dpm_sclk или rocm-smi (цель: %s МГц ±100 МГц)"
MSG[m09_t_gpu_freq_near]="Частота GPU (GPU_FREQ_MHZ ±100 МГц)"
MSG[m09_gpu_freq_msg]="%s МГц (цель: %s МГц, источник: %s)"
MSG[m09_t_gpu_freq_diff]="Частота GPU (отклонение > 100 МГц)"
MSG[m09_gpu_freq_diff_msg]="%s МГц (цель: %s МГц, отклонение: %s МГц, источник: %s)"
MSG[m09_t_gpu_freq]="Частота GPU"
MSG[m09_gpu_freq_unreadable]="Не читается (нет pp_dpm_sclk, нет rocm-smi) — проверьте вручную"
MSG[m09_stability_title]="Тесты стабильности (необязательно)"
MSG[m09_dry_stability]="[DRY-RUN] Тесты стабильности: имитация подтверждения = ДА, длительность = %s с"
MSG[m09_yes_duration]="BC250_YES=1: длительность по умолчанию 300 с (рекомендуется)."
MSG[m09_duration_prompt]="Длительность тестов стабильности: 300 с (рекомендуется) или 60 с (быстро)? [300/60]: "
MSG[m09_run_stability_prompt]="Запустить тесты стабильности (%s с CPU + %s с GPU)? %s: "
MSG[m09_t_cpu_stability]="Стабильность CPU (stress-ng %s с)"
MSG[m09_t_gpu_stability]="Стабильность GPU (FurMark %s с)"
MSG[m09_stress_cpu_start]="Запуск stress-ng CPU на %s с (задействует все ядра)..."
MSG[m09_finished_ok]="Завершён без ошибок"
MSG[m09_failed_unstable]="Сбой или прерывание — обнаружена нестабильность"
MSG[m09_stress_ng_missing]="stress-ng не установлен (pkg_install stress-ng, чтобы добавить)"
MSG[m09_dry_furmark]="[DRY-RUN] Тест GPU FurMark %s с"
MSG[m09_furmark_start]="Запуск FurMark GPU на %s с..."
MSG[m09_furmark_missing]="FurMark не установлен, тест GPU пропущен"
MSG[m09_stability_skipped]="Тесты стабильности пропущены по запросу пользователя."
MSG[m09_skipped_user]="Пропущено (выбор пользователя)"
MSG[m09_score_excellent]="ОТЛИЧНО"
MSG[m09_score_good]="ХОРОШО"
MSG[m09_score_check]="ПРОВЕРИТЬ"
MSG[m09_report_title]="ОТЧЁТ О ПРОВЕРКЕ BC-250"
MSG[m09_report_passed]="Тестов пройдено"
MSG[m09_report_warnings]="Предупреждений"
MSG[m09_report_failures]="Ошибок"
MSG[m09_report_score]="Общая оценка"
MSG[m09_reco_title]="Рекомендации"
MSG[m09_reco_fail]="  • Некоторые тесты провалены. Проверьте соответствующие модули:
    - ядра CPU не разблокированы       → повторите модуль 03
    - службы systemd неактивны         → journalctl -u <служба> для диагностики
    - частота CPU нестабильна          → вернитесь к модулю 05 (разгон CPU) + стресс-тест
    - VRAM не переключена на 512 МБ    → повторите модуль 02 (BIOS/UEFI)"
MSG[m09_reco_warn]="  • Есть предупреждения:
    - высокие температуры              → проверьте охлаждение (модуль 01)
    - CU / частота GPU вне нормы       → вернитесь к модулям 04, 05, 06
    - отсутствуют инструменты (sensors, FurMark, stress-ng)
      → установите их через ваш пакетный менеджер"
MSG[m09_done]="Модуль 09 завершён (оценка: %s%% — %sP/%sW/%sF)."
