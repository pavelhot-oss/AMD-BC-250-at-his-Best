#!/usr/bin/env bash
# locale/uk.sh — Ukrainian message catalog for bc250-beast. Loaded by
# lib/i18n.sh on top of locale/en.sh (any key missing here falls back to
# English).
#
# Machine-drafted translation: needs review by a native speaker.
#
# Same rules as en.sh:
#   - one   MSG[key]="..."   per message, keys are [a-z0-9_]
#   - values are printf formats: %s = argument, %% = literal percent sign
#   - keep argument ORDER identical to en.sh (bash printf has no
#     positional %1$s), and keep the same number of placeholders
#   - multi-line messages are fine, just keep the closing quote on the last line
#   - escape " as \" and $ as \$
# Validate with: tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / language selection
# ------------------------------------------------------------------
MSG[lang_name]="Українська"
MSG[i18n_invalid]="Невідома мова: %s (доступні: %s)"
MSG[i18n_switched]="Мова: %s (%s)"
MSG[i18n_save_q]="Зберегти цей вибір у файлі конфігурації (%s)?"
MSG[i18n_saved]="Мову збережено в конфігурації: %s"
MSG[i18n_save_failed]="Не вдалося зберегти мову (файл конфігурації не знайдено: %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="Продовжити?"
MSG[common_yn]="[y/N]"
MSG[common_yes_regex]="^[YyТт]$"
MSG[common_continue_anyway_q]="Все одно продовжити?"
MSG[common_empty]="<порожньо>"
MSG[common_need_root]="Цей модуль потрібно запускати від root (sudo)."
MSG[common_hw_check_skipped]="Визначення обладнання пропущено (--force)."
MSG[common_no_bc250]="AMD BC-250 не виявлено (PCI 1002:13fe не знайдено). Використайте --force, щоб обійти цей запобіжник."
MSG[common_bc250_found]="Виявлено AMD BC-250 (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live не вдався, виконується звичайне встановлення (після нього потрібне перезавантаження)"
MSG[common_steamos_unsupported]="Незмінна (immutable) SteamOS не підтримується — посібник рекомендує дистрибутив Bazzite."
MSG[common_unknown_distro_pkg]="Нерозпізнаний дистрибутив, встановіть вручну: %s"
MSG[common_reboot_needed]="Щоб застосувати наведені вище зміни, потрібне перезавантаження."
MSG[common_reboot_now_q]="Перезавантажити зараз?"
MSG[common_reboot_reminder]="Не забудьте перезавантажитися, перш ніж переходити до наступних модулів."
MSG[common_config_created]="Конфігурацію не знайдено, приклад скопійовано до %s (підлаштуйте його під свою плату)."
MSG[common_config_missing]="Файл конфігурації не знайдено: %s"
MSG[common_banner_tagline]="AMD BC-250 -> Steam Machine на повну потужність"
MSG[common_m01_not_confirmed]="Модуль 01 (охолодження/живлення) не підтверджено."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh — єдина точка входу bc250-beast.

Перетворює AMD BC-250 на «звіра» (beast), запускаючи в порядку,
рекомендованому спільнотою (синтез Old Lamer, docs/guide_old_lamer.md),
вбудовані інструменти (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, Forbidden-Darkness UEFI BIOS) та кілька
системних налаштувань (zswap, mitigations, MangoHud).

Використання:
  sudo ./install.sh                 # інтерактивне меню
  sudo ./install.sh --all           # запустити всі модулі по черзі
  sudo ./install.sh --module 05     # запустити лише модуль 05
  sudo ./install.sh --status        # швидка діагностика поточного стану
  sudo ./install.sh --lang uk       # мова інтерфейсу: коди = файли в locale/
                                    # (також BC250_LANG чи UI_LANG у конфігу)
  sudo ./install.sh --all --yes     # неінтерактивний режим (бере значення з
                                    # конфігурації без підтвердження кожного
                                    # кроку — лише для повторного розгортання
                                    # конфігурації, вже перевіреної вручну)
  sudo ./install.sh --force ...     # пропустити визначення BC-250 через PCI
                                    # (корисно для dev / CI без обладнання)"

MSG[mod_00_desc]="Попередні перевірки (обладнання, дистрибутив, залежності)"
MSG[mod_01_desc]="Охолодження та живлення (фізичний чекліст)"
MSG[mod_02_desc]="Модифікований BIOS/UEFI (8 ядер вбудовано + 512MB VRAM)"
MSG[mod_03_desc]="Розблокування 8 ядер CPU (програмне, зі збереженням)"
MSG[mod_04_desc]="Розблокування Compute Unit GPU (до 40 CU)"
MSG[mod_05_desc]="Розгін / зниження напруги CPU (SMU)"
MSG[mod_06_desc]="Розгін GPU (регулятор cyan-skillfish)"
MSG[mod_07_desc]="Налаштування системи (zswap, mitigations, MangoHud)"
MSG[mod_08_desc]="Додаткові опції (корпуси, NullVRS, посилання спільноти)"
MSG[mod_09_desc]="Перевірка та бенчмарк"

MSG[inst_module_not_found]="Модуль не знайдено: %s"
MSG[inst_module_failed]="Модуль %s завершився з помилкою (код виходу %s). Послідовність зупинено — усуньте проблему, потім запустіть знову з --module %s."
MSG[inst_status_title]="Поточний стан"
MSG[inst_status_bc250_yes]="Виявлено AMD BC-250."
MSG[inst_status_bc250_no]="AMD BC-250 у цій системі не виявлено."
MSG[inst_status_distro]="Дистрибутив: %s"
MSG[inst_status_threads]="Потоки CPU    : %s"
MSG[inst_status_mitig_off]="Mitigations   : вимкнено"
MSG[inst_status_mitig_on]="Mitigations   : увімкнено (стандартно)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Активний swap : так"
MSG[inst_status_swap_no]="Активний swap : ні"
MSG[inst_status_unlock_svc]="Розблок. 8 ядер (сервіс) : увімкнено"
MSG[inst_status_oc_svc]="Розгін CPU (сервіс)      : увімкнено"
MSG[inst_status_umr_yes]="umr           : встановлено"
MSG[inst_status_umr_no]="umr           : відсутній"
MSG[inst_status_gpu_hint]="Деталі GPU (таблиця WGP / активні CU):"
MSG[inst_menu_config]="Конфігурація  : %s"
MSG[inst_menu_lang]="Мова          : %s"
MSG[inst_menu_all]="a) Запустити все в рекомендованому порядку"
MSG[inst_menu_status]="s) Стан / діагностика"
MSG[inst_menu_edit]="e) Редагувати конфігурацію (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Language / Мова"
MSG[inst_menu_quit]="q) Вийти"
MSG[inst_prompt_choice]="Вибір: "
MSG[inst_press_enter]="Натисніть Enter, щоб продовжити..."
MSG[inst_done_press_enter]="Готово. Натисніть Enter, щоб продовжити..."
MSG[inst_invalid_choice]="Неприпустимий вибір."
MSG[inst_unknown_arg]="Невідомий аргумент: %s (див. --help)"
MSG[inst_module_needs_id]="--module потребує ідентифікатора (напр. 05-cpu-overclock або 05)"
MSG[inst_no_module_number]="Жоден модуль не відповідає номеру %s"
MSG[inst_lang_needs_arg]="--lang потребує коду мови (доступні: %s)"
MSG[inst_final_validation_q]="Запустити фінальну перевірку (модуль 09)?"
MSG[inst_yes_mode_validation]="Режим --yes: фінальна перевірка запускається автоматично."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh — видаляє ПОСТІЙНІ зміни, встановлені bc250-beast.
Не чіпає прошитий BIOS (модуль 02) та охолодження/проводку (модуль 01).

Використання:
  sudo ./uninstall.sh [--lang <code>]"
MSG[uninst_title]="Видалення постійних змін bc250-beast"
MSG[uninst_rm_core_unlock]="Видалення сервісу bc250-core-unlock..."
MSG[uninst_disable_smu_oc]="Вимкнення сервісу bc250-smu-oc (налаштування розгону CPU)..."
MSG[uninst_gpu_stock]="Відновлення стандартної таблиці WGP (24 CU) та видалення сервісу автозапуску..."
MSG[uninst_rm_file]="Видалення %s"
MSG[uninst_kargs]="Видалення доданих аргументів ядра (zswap, mitigations)..."
MSG[uninst_kargs_reboot]="Щоб застосувати видалення аргументів ядра, потрібне перезавантаження."
MSG[uninst_swap_kept_1]="Swap-файл Btrfs (/var/swap) та його рядок у fstab НЕ було видалено"
MSG[uninst_swap_kept_2]="автоматично (деструктивна дія). За потреби видаліть їх вручну:"
MSG[uninst_done_1]="Видалення завершено. Прошитий BIOS (модуль 02) та проводка"
MSG[uninst_done_2]="(модуль 01) залишаються на місці — це апаратні зміни."

# ------------------------------------------------------------------
# Module 00 — preflight
# ------------------------------------------------------------------
MSG[m00_title]="00 - Попередні перевірки"
MSG[m00_q_test_boot]="Чи виконали ви тестове завантаження (блок живлення + клавіатура + DisplayPort) і чи підтвердили доступ до BIOS, перш ніж продовжувати?"
MSG[m00_dry_test_boot]="[DRY-RUN] Питання про тестове завантаження: %s"
MSG[m00_strongly_recommended]="Наполегливо рекомендується перед будь-якими змінами."
MSG[m00_abort_user]="Зупинено на вимогу користувача. Виконайте тестове завантаження, потім запустіть знову."
MSG[m00_distro_detected]="Виявлений дистрибутив: %s"
MSG[m00_distro_unknown]="Дистрибутив не розпізнано автоматично. Модулі можуть зазнати невдачі на етапах встановлення пакетів."
MSG[m00_kernel]="Ядро: %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Відсутні інструменти: %s"
MSG[m00_install_deps_q]="Встановити базові залежності зараз?"
MSG[m00_deps_ok]="Усі базові залежності наявні."
MSG[m00_done]="Попередні перевірки завершено."

# ------------------------------------------------------------------
# Module 01 — cooling & power
# ------------------------------------------------------------------
MSG[m01_title]="01 - Охолодження та живлення (фізичні кроки)"
MSG[m01_checklist]="Цей модуль нічого не змінює на машині: охолодження та живлення —
це апаратні кроки, які потрібно виконати ДО програмного розгону
(модулі 05/06), інакше ви ризикуєте отримати збої, тротлінг або
навіть пошкодження обладнання.

Чекліст (деталі — у docs/guide_old_lamer.md, розділи 2 та 3):

  [ ] Охолодження обрано та встановлено:
        - водяне охолодження AIO 240 мм (найкращий варіант, <60°C
          під навантаженням)
        - або 1x вентилятор 120 мм (напр. Arctic P12 Pro) на частково
          відкритому радіаторі (вирізати ЛИШЕ зону вентилятора)
  [ ] Термопасту на APU замінено: PTM 7950 (виграш 5-8°C)
  [ ] Термозамазку (thermal putty) нанесено на VRM + чипи GDDR
  [ ] Пасивний радіатор приклеєно на бекплейт (зона RAM/VRAM)
  [ ] Пластикові шайби додано під пружинні гвинти центрального
        радіатора (притискання PTM 7950).
  [ ] Якщо вживаний вентилятор без PWM: ніколи не нижче 1800 RPM.
  [ ] Блок живлення підібрано правильно: щонайменше 25 А по лінії 12 В
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / серверний блок
        живлення Dell-HP з перевіреною розпіновкою)
  [ ] Якщо плату розблоковано до 40 CU + сильно розігнано (>300 Вт):
        2x роз'єми Molex Microfit 3.0 (43025-0800) додано поруч з
        оригінальним роз'ємом PCIe, дроти щонайменше AWG18

⚠️  Єдиний оригінальний роз'єм PCIe може РОЗПЛАВИТИСЯ під великим
    навантаженням (40 CU розблоковано + розгін). Не підіймайте розгін
    GPU (модуль 06) без цього кроку, якщо ви цілите вище ~250-300 Вт.
"
MSG[m01_confirm_q]="Чи підтверджуєте ви, що охолодження та живлення встановлено й перевірено?"
MSG[m01_confirmed]="Фізичний крок підтверджено користувачем. Можна продовжувати."
MSG[m01_not_confirmed]="Крок не підтверджено. Наполегливо рекомендується виконати його, перш ніж переходити до розгону (модулі 05/06)."

# ------------------------------------------------------------------
# Module 02 — BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - Модифікований BIOS/UEFI (8 ядер вбудовано + 512MB VRAM)"
MSG[m02_intro]="Цей крок прошиває модифікований BIOS (Forbidden-Darkness UEFI Menu Script),
який:
  - вбудовує розблокування 8 ядер CPU безпосередньо в меню BIOS
    (постійно, без потреби перезапускати скрипт після кожного холодного
    завантаження)
  - дозволяє змінити виділення VRAM з 8 ГБ (за замовчуванням) на 512 МБ,
    що потрібно для динамічного розподілу RAM/VRAM в іграх

Процедура (стисло — візуальні деталі дивіться в офіційному відео проєкту,
посилання в docs/guide_old_lamer.md, розділ 4):

  1. Потрібна відформатована USB-флешка.
  2. Цей скрипт копіює reboot-uefi.sh + архів Firmware.7z на флешку.
  3. Ви запустите reboot-uefi.sh з опцією 4 (розпакувати .7z на флешку),
     потім з опцією 2 (одноразове завантаження з флешки через efibootmgr).
  4. В оболонці UEFI: fs1: -> запустіть утиліту прошивки з архіву ->
     зробіть резервну копію старого BIOS (префікс -O) -> прошийте новий
     (-P -N).
  5. Скиньте CMOS (перемичка або вийміть батарейку на 20-30 с).
  6. У новому BIOS: увімкніть \"Unlock CPU cores\" і поверніть VRAM на
     512 МБ (значення задається в конфігурації: BIOS_TARGET_VRAM_MB).

⚠️  Невдала прошивка BIOS може зробити плату непридатною. Дотримуйтеся
    процедури буквально та збережіть резервну копію старого BIOS."
MSG[m02_no_removable]="Знімних пристроїв не виявлено."
MSG[m02_yes_mode_skip_1]="BC250_YES=1: прошивка BIOS — фізичний крок (перезавантаження в оболонку UEFI + ручні"
MSG[m02_yes_mode_skip_2]="дії), який неможливо зробити неінтерактивним. Крок копіювання на USB-флешку пропущено."
MSG[m02_usb_prompt]="Точка монтування цільової USB-флешки (напр. /run/media/\$USER/USBSTICK), порожньо — пропустити: "
MSG[m02_copying]="Копіювання reboot-uefi.sh та Firmware.7z до %s ..."
MSG[m02_copied]="Файли скопійовано. Потім запустіть, З USB-ФЛЕШКИ:"
MSG[m02_copy_skipped]="Копіювання пропущено. Можете запустити вручну:"
MSG[m02_yes_mode_tool_1]="BC250_YES=1: reboot-uefi.sh — інтерактивний інструмент (меню, запити), автоматично не запускається."
MSG[m02_yes_mode_tool_2]="Запустіть його самостійно: sudo bash '%s'"
MSG[m02_run_tool_q]="Запустити інтерактивний інструмент reboot-uefi.sh зараз (опції меню 4, потім 2)?"
MSG[m02_reminder_1]="Нагадування: після прошивки + скидання CMOS зайдіть у BIOS, щоб увімкнути"
MSG[m02_reminder_2]="\"Unlock CPU cores\" і встановити VRAM на %s МБ, перш ніж продовжувати."
MSG[m02_flashed_q]="Чи прошито BIOS і чи увімкнено опцію 'Unlock CPU cores' у BIOS?"
MSG[m02_flag_created]="Створено прапорець bios_flashed.flag — модуль 03 виявить модифікований BIOS."
MSG[m02_flag_not_created]="Прапорець не створено. Модуль 03 спробує програмне розблокування (не зберігається)."
MSG[m02_bios_check]="Поточна версія BIOS: %s (образи прошивки засновані на BIOS 3.00)"
MSG[m02_extract_note]="На цьому пристрої немає розпакувальника 7z (7z/7za/bsdtar) — Firmware.7z скопійовано в корінь флешки. Розпакуйте його там через утиліту UEFI (опція 4) перед прошиванням."
MSG[m02_backup_hint]="У меню UEFI: СПОЧАТКУ виконайте [menu 0f], щоб експортувати поточну ROM у \\Firmware_Backup\\bc250-backup.rom (відновлення через [menu fr]), ПОТІМ прошийте вибраний профіль."
MSG[m02_flag_not_auto]="BC250_YES=1: bios_flashed.flag НЕ створено. Прошивка — це реальний фізичний крок — запустіть інтерактивно та підтвердіть, коли новий BIOS справді встановлено."

# ------------------------------------------------------------------
# Module 03 — CPU core unlock
# ------------------------------------------------------------------
MSG[m03_title]="03 - Розблокування 8 ядер CPU"
MSG[m03_bios_detected_1]="Виявлено модифікований BIOS. Розблокування 8 ядер виконується самим BIOS."
MSG[m03_bios_detected_2]="Не забудьте перевірити, що опцію 'Unlock CPU cores' увімкнено в меню BIOS."
MSG[m03_stop_governor]="Тимчасова зупинка cyan-skillfish-governor-smu (потрібно для запису в SMU)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 у конфігурації, модуль пропущено."
MSG[m03_attempt]="Спроба розблокувати ядра CPU..."
MSG[m03_mask_written]="Маску присутності ядер CPU успішно записано."
MSG[m03_unlock_failed_1]="Розблокування не вдалося. Дивіться вивід вище. Нестандартна маска (≠0x77)"
MSG[m03_unlock_failed_2]="вказує на справжній дефект кристала: перечитайте modules/03-cpu-core-unlock, перш ніж форсувати."
MSG[m03_install_service_q]="Встановити сервіс systemd для збереження (повторно застосовується при кожному завантаженні)?"
MSG[m03_service_installed]="Сервіс bc250-core-unlock.service встановлено та увімкнено."
MSG[m03_takes_effect_after_reboot]="Розблокування набуде чинності ПІСЛЯ перезавантаження (запис у SMU вмикає ядра лише при наступному завантаженні)."
MSG[m03_no_persistence]="Збереження не встановлено: запускайте цей модуль знову після кожного повного вимкнення живлення."
MSG[m03_reboot_q]="Перезавантажити зараз, щоб увімкнути 8 ядер?"

# ------------------------------------------------------------------
# Module 04 — GPU CU unlock
# ------------------------------------------------------------------
MSG[m04_title]="04 - Розблокування Compute Unit (CU) GPU"
MSG[m04_umr_missing]="umr не знайдено, встановлення через вбудований інструмент..."
MSG[m04_immutable_reboot]="Незмінна система (rpm-ostree): перед продовженням потрібне перезавантаження."
MSG[m04_rerun_after_reboot]="Запустіть цей модуль знову після перезавантаження."
MSG[m04_current_table]="Поточна таблиця WGP:"
MSG[m04_mode_full]="Режим у конфігурації: FULL -> розблокування всіх 40 CU (20 WGP)."
MSG[m04_mode_factory]="Режим у конфігурації: FACTORY -> відновлення стандартної таблиці (24 CU)."
MSG[m04_mode_custom]="Режим у конфігурації: CUSTOM -> повне розблокування, потім маскування перелічених WGP."
MSG[m04_disable_wgp]="Вимкнення дефектного WGP: %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom, але GPU_CU_DISABLE_LIST порожній, нічого маскувати."
MSG[m04_unknown_mode]="Невідомий GPU_CU_MODE у конфігурації: %s (очікується: full|factory|custom)"
MSG[m04_new_table]="Нова таблиця WGP:"
MSG[m04_test_stability]="Перевірте стабільність зараз (FurMark Vulkan + гра), ПЕРШ НІЖ робити це налаштування постійним."
MSG[m04_make_permanent_q]="Конфігурація стабільна, зробити її постійною при завантаженні (write-service-table + install-service)?"
MSG[m04_permanent_done]="Таблицю збережено, сервіс відновлення при завантаженні встановлено."
MSG[m04_live_only]="Налаштування застосовано лише НАЖИВО: воно буде втрачене після наступного перезавантаження."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Альтернативний метод \"патчене ядро\" (vendor/bc250-40cu-unlock):
  корисний, якщо ваша harvest map НЕ симетрична (вимкнені пари розкидані
  по різних місцях, а не всі з одного боку). Дивіться:
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Цей модуль (live manager) залишається рекомендованим першим методом.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Module 05 — CPU overclock
# ------------------------------------------------------------------
MSG[m05_title]="05 - Розгін / зниження напруги CPU"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s перевищує абсолютну межу безпеки 1300 мВ. Виправте config/bc250-beast.conf."
MSG[m05_install_stress]="Встановлення інструмента стрес-тестування 'stress-ng'..."
MSG[m05_install_smu_oc]="Встановлення bc250-smu-oc з вбудованої копії..."
MSG[m05_apply_q]="Застосувати %s МГц @ %s мВ зараз?"
MSG[m05_applying]="Застосування розгону ЗІ збереженням (--keep): %s МГц @ %s мВ (ліміт температури %s°C)"
MSG[m05_detect_failed]="bc250-detect не спрацював — повернення до стандартних значень."
MSG[m05_config_missing]="Стабільну конфігурацію не створено (overclock.conf відсутній) — повернення до стандартних значень."
MSG[m05_threads_warn_1]="Видно %s потоків (очікується 16 після розблокування 8 ядер) — чи"
MSG[m05_threads_warn_2]="перезавантажувалися ви після модуля 03? Стрес-тест усе одно використає %s потоків."
MSG[m05_stress_start]="Стрес-тест CPU протягом %s с (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Стрес-тест не пройдено — повернення до стандартних значень."
MSG[m05_reverted]="Повернуто до стандартних значень."
MSG[m05_stable_q]="Система залишилася стабільною, зробити це налаштування постійним при завантаженні?"
MSG[m05_apply_install_failed]="Не вдалося записати конфігурацію завантаження (bc250-apply --install не спрацював)."
MSG[m05_service_enabled]="Сервіс bc250-smu-oc увімкнено при завантаженні з %s МГц @ %s мВ."
MSG[m05_service_missing]="bc250-smu-oc.service не створено — розгін не застосовуватиметься при завантаженні."
MSG[m05_service_enable_failed]="Не вдалося ввімкнути bc250-smu-oc.service при завантаженні."
MSG[m05_not_permanent]="Налаштування не зроблено постійним — повернення до стандартних значень."
MSG[m05_monitoring_tip]="
Поради з моніторингу:
  - amdgpu_top (метрики SMU наживо)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (помітити clock stretching)"

# ------------------------------------------------------------------
# Module 06 — GPU governor
# ------------------------------------------------------------------
MSG[m06_title]="06 - Розгін GPU (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Відсутні залежності для збірки:"
MSG[m06_install_with]="Встановіть за допомогою:"
MSG[m06_arch_libudev_note]="  # libudev надається systemd на Arch/CachyOS, окремий пакет не потрібен"
MSG[m06_ostree_build_env]="Середовище збірки буде доступне після перезавантаження (незмінна система rpm-ostree)"
MSG[m06_unknown_distro_deps]="Нерозпізнаний дистрибутив (%s). Встановіть вручну: git, make, cargo, pkg-config, заголовки libudev."
MSG[m06_deps_ok]="Усі залежності для збірки наявні."
MSG[m06_cloning]="Клонування cyan-skillfish-governor (гілка smu)..."
MSG[m06_repo_update]="Репозиторій уже наявний, оновлення..."
MSG[m06_pull_failed]="Pull не вдався, продовжуємо з наявною локальною копією."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release у %s"
MSG[m06_building]="Збірка регулятора (cargo build --release)..."
MSG[m06_build_failed]="cargo build не вдався. Перевірте помилки вище."
MSG[m06_build_ok]="Збірку завершено успішно. Бінарний файл: %s"
MSG[m06_follow_readme]="Встановлення з %s:
    бінарний файл, політика D-Bus, обгортка performance-mode і
    сервіс systemd cyan-skillfish-governor-smu.
Сервіс запускається одразу (перезавантаження не потрібне)."
MSG[m06_installed_q]="Встановити регулятор (бінарний файл + сервіс systemd) і застосувати налаштування нижче?"
MSG[m06_config_postponed]="Встановлення пропущено. Запустіть цей модуль знову, щоб встановити та запустити регулятор."
MSG[m06_generating]="Генерація %s (крива idle -> ціль, цільова температура %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] Запис %s:"
MSG[m06_toml_header]="# Згенеровано bc250-beast — модуль 06
# Типові значення upstream можуть бути нестабільними: перевірте вручну,
# перш ніж вмикати при завантаженні."
MSG[m06_file_written]="Файл записано: %s"
MSG[m06_progression]="Рекомендована Old Lamer прогресія:
  1500 МГц (сток) -> 2000 МГц (легкий крок, ~10%%+ у FurMark)
  -> перевірити CPU на 3,85 ГГц (модуль 05) -> розганяти GPU далі
  ТІЛЬКИ якщо охолодження встигає (водянка: повідомляють до ~2,4 ГГц,
  ~360 Вт / 30 А, звідси важливість додаткових роз'ємів Molex
  з модуля 01).

  ВАЖЛИВО: після запуску сервісу дайте реальне навантаження на GPU
  (FurMark Vulkan + гра) на кілька хвилин і перевірте логи
  (journalctl -u cyan-skillfish-governor-smu), перш ніж довіряти."

# ------------------------------------------------------------------
# Module 07 — system tuning
# ------------------------------------------------------------------
MSG[m06_bin_installed]="Бінарний файл встановлено: %s"
MSG[m06_perf_installed]="Обгортку performance-mode встановлено: %s"
MSG[m06_dbus_installed]="Політику D-Bus встановлено: %s"
MSG[m06_service_installed]="Сервіс systemd встановлено: %s"
MSG[m06_started]="Сервіс регулятора активний."
MSG[m06_start_failed]="Сервіс регулятора запустився з помилками. Перевірте сервіс:"
MSG[m06_enable_boot_q]="Увімкнути сервіс регулятора під час завантаження (повторно застосовує розгін при кожному старті)?"
MSG[m06_enabled]="Сервіс увімкнено при завантаженні."
MSG[m07_title]="07 - Налаштування системи (zswap / mitigations / MangoHud)"
MSG[m07_zswap_ostree]="Увімкнення zswap + mitigations=off через аргументи ядра (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] Було б потрібне перезавантаження (незмінна система rpm-ostree)."
MSG[m07_ostree_reboot]="Потрібне перезавантаження (незмінна система rpm-ostree)."
MSG[m07_rerun_after_reboot]="Запустіть цей модуль знову після перезавантаження: він виявить, що аргументи ядра вже активні."
MSG[m07_var_not_btrfs_1]="/var у цій системі не на Btrfs — офіційна процедура (окремий swap-файл"
MSG[m07_var_not_btrfs_2]="на Btrfs) як є не застосовна. Створіть звичайний swap-файл вручну"
MSG[m07_var_not_btrfs_3]="або пропустіть цей підмодуль, якщо ви не на Bazzite/Btrfs."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (якщо є)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (потрібне перезавантаження)"
MSG[m07_dry_final_check]="[DRY-RUN] Фінальна перевірка: rpm-ostree kargs, zswap увімкнено, swappiness, swapon --show"
MSG[m07_swapoff]="Вимкнення наявного swap..."
MSG[m07_rm_old_swap]="Видалення старого /var/swap..."
MSG[m07_create_subvol]="Створення підтому Btrfs /var/swap..."
MSG[m07_selinux_fix]="Виправлення контексту SELinux..."
MSG[m07_semanage_missing]="semanage відсутній, потрібно встановити policycoreutils-python-utils (rpm-ostree, перезавантаження)."
MSG[m07_rerun_selinux]="Запустіть цей підмодуль знову після перезавантаження, щоб завершити налаштування SELinux + створити swap-файл."
MSG[m07_create_swapfile]="Створення swap-файлу розміром %s ГБ..."
MSG[m07_fstab]="Додавання до /etc/fstab..."
MSG[m07_swapon]="Негайне увімкнення swap..."
MSG[m07_swappiness]="Встановлення vm.swappiness=%s (оптимізовано для ігор)..."
MSG[m07_final_check]="Фінальна перевірка:"
MSG[m07_zswap_not_active]="zswap ще не активний (очікується перезавантаження?)"
MSG[m07_mangohud_title]="Встановлення MangoHud (оверлей FPS/температури/завантаження GPU-CPU)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] MangoHud зазвичай попередньо встановлений на Bazzite. Перевірка: command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud попередньо встановлений на SteamOS — встановлення пропущено"
MSG[m07_mangohud_bazzite_check]="MangoHud зазвичай попередньо встановлений на Bazzite. Перевірка..."
MSG[m07_mangohud_present]="MangoHud уже наявний."
MSG[m07_mangohud_steamos]="MangoHud попередньо встановлений на SteamOS — встановлення пропущено"
MSG[m07_mangohud_steam_hint]="Щоб увімкнути його в Steam: додайте 'mangohud %%command%%' до параметрів запуску гри."
MSG[m07_zswap_already]="zswap уже увімкнено на рівні ядра, переходимо одразу до створення swap-файлу."
MSG[m07_zswap_other_distro_1]="Офіційна процедура zswap+swap-файл задокументована лише для Bazzite/rpm-ostree+Btrfs."
MSG[m07_zswap_other_distro_2]="На %s: увімкніть zswap через GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="потім перегенеруйте конфігурацію завантажувача (grub-mkconfig / bootctl тощо, залежно від вашої системи) і створіть звичайний swap-файл."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 у конфігурації, крок пропущено."
MSG[m07_zswap_zram_active]="zram вже забезпечує стиснутий swap у цій системі (%s) — zswap пропущено (запуск обох лише додасть накладних витрат через подвійне стиснення)."
MSG[m07_mitig_title]="Вимкнення захисту CPU від вразливостей (mitigations: Spectre/Meltdown)"
MSG[m07_mitig_warn_1]="Це знижує захист від деяких локальних атак (side-channel)."
MSG[m07_mitig_warn_2]="Рекомендується лише на виділеній ігровій машині, а не на чутливій багатоцільовій робочій станції."
MSG[m07_mitig_confirm_q]="Підтвердити вимкнення захисту CPU (mitigations)?"
MSG[m07_mitig_ostree_done]="mitigations=off уже застосовано через setup_zswap_ostree (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Додайте 'mitigations=off' до GRUB_CMDLINE_LINUX (або до конфігурації systemd-boot),"
MSG[m07_mitig_grub_2_dry]="потім перегенеруйте конфігурацію завантажувача (grub-mkconfig / bootctl тощо) і перезавантажтеся."
MSG[m07_mitig_grub_2]="потім перегенеруйте конфігурацію завантажувача і перезавантажтеся."
MSG[m07_mitig_done]="Захист CPU (mitigations) вимкнено (набуде чинності після перезавантаження)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (або не задано), крок пропущено."
MSG[m07_done]="Модуль 07 завершено."

# ------------------------------------------------------------------
# Module 08 — extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Додаткові опції"
MSG[m08_intro]="Цей розділ збирає додаткові опції, згадані у відео Old Lamer,
не обов'язкові для базової роботи:

  1) Рекомендовані корпуси для 3D-друку
       - NextGen3D (магазин)  : https://nexgen3d.bigcartel.com/
       - NextGen3D (моделі)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro з водяним охолодженням 240 мм:
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Альтернатива з повітряним кулером CPU:
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (шар Vulkan, корисний для деяких ігор, як-от Doom: The
     Dark Ages, на урізаному GPU): https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling через Decky Loader (Frame Generation)
       - Потребує заздалегідь встановленого Decky Loader на системах типу
         Bazzite/SteamOS (сюди не входить, дивіться офіційний Decky Loader).

  4) 3.5\" IPS USB-екран моніторингу (Turing Smart Screen):
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Спільноти:
       Discord: https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU): https://t.me/BC250public"
MSG[m08_no_home]="Не вдалося визначити домашній каталог користувача %s."
MSG[m08_dry_download]="[DRY-RUN] Завантаження %s"
MSG[m08_dry_extract]="[DRY-RUN] Розпакування до /tmp/nullvrs і копіювання *.json + *.so до %s"
MSG[m08_downloading]="Завантаження NullVRS 1.0.0..."
MSG[m08_nullvrs_installed]="NullVRS встановлено в %s (власник: %s):"
MSG[m08_files_not_found]="Файли не знайдено, перевірте завантажений архів."
MSG[m08_repo_update]="Репозиторій уже наявний у %s, оновлення..."
MSG[m08_pull_failed]="Pull не вдався."
MSG[m08_cloning_turing]="Клонування turing-smart-screen-python..."
MSG[m08_cloned_in]="Клоновано до:"
MSG[m08_turing_steps]="Наступні кроки (вручну, залежно від вашого дистрибутива):
  1) cd %s
  2) Створіть віртуальне середовище Python: python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Налаштуйте екран (дивіться README репозиторію: config.yaml, поворот, USB-порт)
  5) Перевірте: python main.py
  6) Для сервісу systemd: скопіюйте turing-screen.service до /etc/systemd/system/ і підправте шляхи"
MSG[m08_see_readme]="Повне налаштування дивіться в README репозиторію."
MSG[m08_community_title]="Посилання спільноти BC-250"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="Магазин NextGen3D"
MSG[m08_lbl_models]="Моделі на Printables"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="Альтернатива з повітряним кулером CPU"
MSG[m08_submenu_title]="Підменю додаткових опцій"
MSG[m08_opt_1]="1) Встановити Vulkan NullVRS (v1.0.0)"
MSG[m08_opt_2]="2) Підготувати Turing Smart Screen 3.5\" (клонування + інструкції)"
MSG[m08_opt_3]="3) Показати посилання спільноти (відформатовано)"
MSG[m08_opt_q]="q) Назад / Вийти"
MSG[m08_prompt]="Вибір [1-3/q]: "
MSG[m08_done]="Модуль 08 завершено."

# ------------------------------------------------------------------
# Module 09 — validation
# ------------------------------------------------------------------
MSG[m09_title]="09 - Перевірка та бенчмарк"
MSG[m09_invalid_status]="Неприпустимий статус для report_result: %s"
MSG[m09_dry_cmd]="[DRY-RUN] Команда: %s"
MSG[m09_instant_title]="Миттєві перевірки"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Перевірка кількості ядер CPU (очікується: 16 потоків / 8 фізичних ядер)"
MSG[m09_t_cpu_cores_16]="Ядра CPU (16 потоків / 8 ядер)"
MSG[m09_threads_detected]="виявлено %s потоків"
MSG[m09_t_cpu_cores_8]="Ядра CPU (8 потоків / 4 ядра)"
MSG[m09_threads_not_unlocked]="%s потоків — розблокування 8 ядер не застосовано (модуль 03)"
MSG[m09_threads_bios_unlocked]="%s потоків — розблокування 8 ядер активне через модифікований BIOS (модуль 02)"
MSG[m09_threads_bios_not_enabled]="%s потоків — увімкніть «Unlock CPU cores» у модифікованому BIOS"
MSG[m09_t_cpu_cores]="Ядра CPU"
MSG[m09_threads_unexpected]="%s потоків — неочікувано"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Перевірка частоти CPU (конфігурація: %s МГц ±100 МГц)"
MSG[m09_t_cpu_freq_near]="Частота CPU (близько до CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s МГц під навантаженням (ціль: %s МГц)"
MSG[m09_t_cpu_freq_diff200]="Частота CPU (відхилення ≤ 200 МГц)"
MSG[m09_t_cpu_freq_diff_gt200]="Частота CPU (відхилення > 200 МГц)"
MSG[m09_freq_target_diff]="%s МГц (ціль: %s МГц, відхилення: %s МГц)"
MSG[m09_freq_under_target]="%s МГц під навантаженням (ціль: %s МГц, відхилення: %s МГц) — OC не застосовано (модуль 05) або троттлінг"
MSG[m09_t_cpu_freq]="Частота CPU"
MSG[m09_cpuinfo_unreadable]="Не вдалося прочитати /proc/cpuinfo"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Перевірка активних CU GPU через bc250-cu-live-manager (конфігурація: %s)"
MSG[m09_t_gpu_cu_match]="Активні CU GPU (збіг із GPU_CU_MODE)"
MSG[m09_cu_active_expected]="%s активних CU (очікується: %s)"
MSG[m09_t_gpu_cu_mismatch]="Активні CU GPU (≠ GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="%s активних CU (очікується: %s для режиму %s)"
MSG[m09_t_gpu_cu]="Активні CU GPU"
MSG[m09_cu_detected_mode]="виявлено %s активних CU (режим у конфігурації: %s)"
MSG[m09_cu_parse_fail]="Не вдалося розібрати вивід bc250-cu-live-manager"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager не встановлено або не є виконуваним"
MSG[m09_dry_services]="[DRY-RUN] Перевірка сервісів systemd (bc250-core-unlock.service, bc250-smu-oc.service, cyan-skillfish-governor-smu.service)"
MSG[m09_t_service]="Сервіс %s"
MSG[m09_svc_active]="активний"
MSG[m09_svc_enabled_inactive]="увімкнений, але не активний (ще запускається?)"
MSG[m09_svc_inactive]="неактивний / не увімкнений"
MSG[m09_svc_bios_governs]="не потрібен — ядра керуються модифікованим BIOS (модуль 02)"
MSG[m09_dry_vram]="[DRY-RUN] Перевірка виділення VRAM у BIOS (ціль: %s МБ)"
MSG[m09_t_vram_target]="VRAM у BIOS (%s МБ)"
MSG[m09_vram_detected]="виявлено %s МБ"
MSG[m09_t_vram_default]="VRAM у BIOS (8 ГБ = заводське значення)"
MSG[m09_vram_default_msg]="VRAM на 8 ГБ (за замовчуванням), перемикання на 512 МБ не застосовано (модуль 02)"
MSG[m09_t_vram]="VRAM у BIOS"
MSG[m09_vram_detected_target]="виявлено %s МБ (ціль: %s МБ)"
MSG[m09_vram_unknown]="Не вдалося визначити виділення VRAM"
MSG[m09_dry_temps]="[DRY-RUN] Перевірка температур CPU/GPU через sensors"
MSG[m09_t_cpu_temp_ok]="Температура CPU (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="Температура GPU (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="Температура CPU (> 85°C)"
MSG[m09_t_gpu_temp_high]="Температура GPU (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C — перевірте охолодження (модуль 01)"
MSG[m09_t_cpu_temp]="Температура CPU"
MSG[m09_t_gpu_temp]="Температура GPU"
MSG[m09_temp_not_detected]="Не виявлено через sensors"
MSG[m09_t_temps]="Температура CPU/GPU"
MSG[m09_sensors_missing]="Команда 'sensors' недоступна (lm-sensors не встановлено)"
MSG[m09_dry_voltage]="[DRY-RUN] Перевірка напруги CPU через bc250_smu_oc або sensors (жорстка межа: 1300 мВ, допуск ±50 мВ від CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="Напруга CPU (≤ 1300 мВ, допуск ±50 мВ)"
MSG[m09_t_voltage_danger]="Напруга CPU (> 1300 мВ = НЕБЕЗПЕКА)"
MSG[m09_voltage_danger_msg]="%s мВ (джерело: %s) — ПЕРЕВИЩУЄ АБСОЛЮТНУ МЕЖУ БЕЗПЕКИ"
MSG[m09_voltage_ok_msg]="%s мВ (ціль: %s мВ, джерело: %s)"
MSG[m09_t_voltage_diff]="Напруга CPU (відхилення > 50 мВ)"
MSG[m09_voltage_diff_msg]="%s мВ (ціль: %s мВ, відхилення: %s мВ, джерело: %s)"
MSG[m09_t_voltage]="Напруга CPU"
MSG[m09_voltage_unreadable]="Напругу не вдалося прочитати (bc250_smu_oc, bc250_detect.py, sensors Vcore) — перевірте вручну"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Перевірка частоти GPU через pp_dpm_sclk або rocm-smi (ціль: %s МГц ±100 МГц)"
MSG[m09_t_gpu_freq_near]="Частота GPU (GPU_FREQ_MHZ ±100 МГц)"
MSG[m09_gpu_freq_msg]="%s МГц верхній стан (ціль: %s МГц, поточний: %s МГц)"
MSG[m09_t_gpu_freq_diff]="Частота GPU (відхилення > 100 МГц)"
MSG[m09_gpu_freq_diff_msg]="%s МГц верхній стан (ціль: %s МГц, відхилення: %s МГц, поточний: %s МГц)"
MSG[m09_t_gpu_freq]="Частота GPU"
MSG[m09_gpu_freq_unreadable]="Не вдалося прочитати (pp_dpm_sclk відсутній, rocm-smi відсутній) — перевірте вручну"
MSG[m09_stability_title]="Тести стабільності (необов'язково)"
MSG[m09_dry_stability]="[DRY-RUN] Тести стабільності: імітоване підтвердження = ТАК, тривалість = %s с"
MSG[m09_yes_duration]="BC250_YES=1: типова тривалість 300 с (рекомендовано)."
MSG[m09_duration_prompt]="Тривалість тесту стабільності: 300 с (рекомендовано) чи 60 с (швидко)? [300/60]: "
MSG[m09_run_stability_prompt]="Запустити тести стабільності (%s с CPU + %s с GPU)? %s: "
MSG[m09_t_cpu_stability]="Стабільність CPU (stress-ng %s с)"
MSG[m09_t_gpu_stability]="Стабільність GPU (FurMark %s с)"
MSG[m09_stress_cpu_start]="Запуск stress-ng CPU на %s с (використовує всі ядра)..."
MSG[m09_finished_ok]="Завершено без помилок"
MSG[m09_failed_unstable]="Збій або переривання — виявлено нестабільність"
MSG[m09_stress_ng_missing]="stress-ng не встановлено (pkg_install stress-ng, щоб додати)"
MSG[m09_dry_furmark]="[DRY-RUN] Тест GPU FurMark %s с"
MSG[m09_furmark_start]="Запуск FurMark GPU на %s с..."
MSG[m09_furmark_missing]="FurMark не встановлено, тест GPU пропущено"
MSG[m09_gpu_pair_mangohud]="Стрес GPU у парі з MangoHud (живий оверлей sclk/темп/VRAM під час тесту — MangoHud ставить модуль 07). Best-effort: якщо FurMark вантажить чистий OpenGL, оверлей не з'явиться, але стрес усе одно триває."
MSG[m09_stability_skipped]="Тести стабільності пропущено на вимогу користувача."
MSG[m09_skipped_user]="Пропущено (вибір користувача)"
MSG[m09_score_excellent]="ВІДМІННО"
MSG[m09_score_good]="ДОБРЕ"
MSG[m09_score_check]="ПЕРЕВІРТЕ"
MSG[m09_report_title]="ЗВІТ ПЕРЕВІРКИ BC-250"
MSG[m09_report_passed]="Пройдено"
MSG[m09_report_warnings]="Попереджень"
MSG[m09_report_failures]="Провалено"
MSG[m09_report_score]="Загальна оцінка"
MSG[m09_reco_title]="Рекомендації"
MSG[m09_reco_fail]="  • Деякі тести не пройдено. Перевірте відповідні модулі:
    - ядра CPU не розблоковано         → запустіть модуль 03 знову
    - сервіси systemd неактивні        → journalctl -u <service> для діагностики
    - частота CPU нестабільна          → див. модуль 05 (розгін CPU) + стрес-тест
    - VRAM не перемкнуто на 512 МБ     → повторіть модуль 02 (BIOS/UEFI)"
MSG[m09_reco_warn]="  • Було видано попередження:
    - високі температури               → перевірте охолодження (модуль 01)
    - CU / частота GPU поза нормою     → перегляньте модулі 04, 05, 06
    - відсутні інструменти (sensors, FurMark, stress-ng)
      → встановіть їх через ваш менеджер пакетів"
MSG[m09_done]="Модуль 09 завершено (Оцінка: %s%% — %sP/%sW/%sF)."
