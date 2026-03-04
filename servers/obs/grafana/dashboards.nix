{
  services.grafana.provision.dashboards.settings = {
    apiVersion = 1;

    providers = [
      {
        name = "homelab";
        orgId = 1;
        type = "file";
        disableDeletion = false;
        updateIntervalSeconds = 20;
        allowUiUpdates = true;
        options = {
          path = "/etc/grafana/dashboards/";
          foldersFromFilesStructure = true;
        };
      }
    ];
  };
}