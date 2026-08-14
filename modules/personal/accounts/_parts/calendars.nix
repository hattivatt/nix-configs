{
  accounts.calendar.basePath = ".local/share/calendars";
  accounts.calendar.accounts = {
    russian_holidays = {
      remote = {
        type = "http";
        url = "https://calendar.google.com/calendar/ical/ru.russian%23holiday%40group.v.calendar.google.com/public/basic.ics";
      };
      pimsync = {
        enable = true;
        extraRemoteStorageDirectives = [
          {
            name = "collection_id";
            params = [
              "russian_holidays"
            ];
          }
        ];
        extraPairDirectives = [
          {
            name = "collection";
            params = [
              "russian_holidays"
            ];
          }
        ];
      };
      khal = {
        enable = true;
        type = "discover";
        color = "#4285f4";
        readOnly = true;
      };
    };
    vietnam_holidays = {
      remote = {
        type = "http";
        url = "https://calendar.google.com/calendar/ical/ru.vietnamese%23holiday%40group.v.calendar.google.com/public/basic.ics";
      };
      pimsync = {
        enable = true;
        extraRemoteStorageDirectives = [
          {
            name = "collection_id";
            params = [
              "vietnam_holidays"
            ];
          }
        ];
        extraPairDirectives = [
          {
            name = "collection";
            params = [
              "vietnam_holidays"
            ];
          }
        ];
      };
      khal = {
        enable = true;
        type = "discover";
        color = "#b39ddb";
        readOnly = true;
      };
    };
    malaysia_holidays = {
      remote = {
        type = "http";
        url = "https://calendar.google.com/calendar/ical/ru.malaysia%23holiday%40group.v.calendar.google.com/public/basic.ics";
      };
      pimsync = {
        enable = true;
        extraRemoteStorageDirectives = [
          {
            name = "collection_id";
            params = [
              "malaysia_holidays"
            ];
          }
        ];
        extraPairDirectives = [
          {
            name = "collection";
            params = [
              "malaysia_holidays"
            ];
          }
        ];
      };
      khal = {
        enable = true;
        type = "discover";
        color = "#08086b";
        readOnly = true;
      };
    };
    thai_holidays = {
      remote = {
        type = "http";
        url = "https://calendar.google.com/calendar/ical/ru.th%23holiday%40group.v.calendar.google.com/public/basic.ics";
      };
      pimsync = {
        enable = true;
        extraRemoteStorageDirectives = [
          {
            name = "collection_id";
            params = [
              "thai_holidays"
            ];
          }
        ];
        extraPairDirectives = [
          {
            name = "collection";
            params = [
              "thai_holidays"
            ];
          }
        ];
      };
      khal = {
        enable = true;
        type = "discover";
        color = "#7cb342";
        readOnly = true;
      };
    };
  };
}
