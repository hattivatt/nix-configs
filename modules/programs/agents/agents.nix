{
  flake.modules.homeManager.agents =
    { config, ... }:
    {
      programs.opencode = {
        enable = true;
        agents = {
          orchestrator = ''
            ---
            mode: primary
            model: opencode-go/gpt-5.6-luna
            permission:
              edit: deny
              bash: deny
              task:
                "*": allow
            ---
            Ты оркестратор. Твоя работа — анализ и координация, не реализация.

            Порядок работы:
            1. Разбери запрос пользователя. Если нужен контекст кодовой базы —
               сначала вызови @explore, не читай файлы пачками сам.
            2. Декомпозируй задачу на независимые подзадачи и составь план.
            3. Каждую подзадачу реализации делегируй сабагенту general через
               task tool. Brief должен быть самодостаточным: сабагент не видит
               наш разговор, только твой текст. Указывай конкретные файлы,
               ожидаемый результат и ограничения.
            4. Независимые подзадачи запускай параллельно, в одном блоке вызовов.
            5. Получив результаты, проверь их целостность. При сомнениях —
               делегируй ревью отдельному сабагенту, не правь код сам.
            6. В финале дай пользователю сводку: что сделано, где, что не
               получилось.

            Запрещено:
            - Редактировать или создавать файлы самостоятельно.
            - Выполнять команды напрямую (это делегируется).
            - Передавать сабагенту расплывчатые формулировки вида «улучши код».
          '';
        };
        settings = {
          "$schema" = "https://opencode.ai/config.json";
          autoupdate = false;
          agent = {
            general = {
              model = "opencode-go/deepseek-v4-flash";
            };
            explore = {
              model = "opencode-go/deepseek-v4-flash";
            };
          };
          permission = {
            edit = "allow";
            bash = {
              "*" = "ask";
              "ls *" = "allow";
              "grep *" = "allow";
              "rg *" = "allow";
              "sort *" = "allow";
              "curl *" = "allow";
              "find *" = "allow";
              "echo *" = "allow";
              "diff *" = "allow";
              "jq *" = "allow";
              "sed *" = "allow";
              "cat *" = "allow";
              "cp *" = "allow";
              "wc *" = "allow";
              "mkdir *" = "allow";
              "head *" = "allow";
              "tail *" = "allow";
              "base64 *" = "allow";
              "timeout *" = "allow";
              "git commit *" = "ask";
              "git branch *" = "ask";
              "git reset *" = "ask";
              "git push *" = "ask";
              "git rebase *" = "ask";
              "git clean *" = "ask";
              "git *" = "allow";
            };
            external_directory = {
              "${config.xdg.dataHome}/clankerland/**" = "allow";
            };
          };
        };
      };
      programs.pi-coding-agent = {
        enable = true;
        configDir = "${config.xdg.configHome}/pi/agent";
      };
      home.shellAliases = {
        pia = ''pi -p --model "opencode-go/deepseek-v4-flash"'';
      };
    };
}
