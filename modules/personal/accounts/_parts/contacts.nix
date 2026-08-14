{
  accounts.contact.basePath = ".local/share/contacts";
  accounts.contact.accounts = {
    disroot = {
      remote = {
        type = "carddav";
        url = "https://cloud.disroot.org/remote.php/dav/";
        userName = "hattivatt";
        passwordCommand = [ "pass" "show" "Mails/disroot_contacts" ];
      };
      pimsync = {
        enable = true;
        extraPairDirectives = [
          {
            name = "collection";
            params = [
              "contacts"
            ];
          }
        ];
      };
      khard = {
        enable = true;
        type = "discover";
      };
    };
  };
}
