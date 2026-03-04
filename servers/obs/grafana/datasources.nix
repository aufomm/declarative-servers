{ config, ... }:
{
  services.grafana.provision.datasources.settings = {
    apiVersion = 1;
    datasources = [
      {
        uid = "vmprometheus";
        name = "vmPrometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:8428";
        basicAuth = false;
        isDefault = true;
      }
      {
        # The VictoriaMetrics plugin
        name = "VictoriaMetrics";
        type = "victoriametrics-metrics-datasource";
        uid = "victoriametrics";
        access = "proxy";
        editable = true;
        url = "http://127.0.0.1:8428";
        basicAuth = false;
        jsonData = {
          httpMethod = "POST";
          manageAlerts = true;
          timeInterval = "15s";
          queryTimeout = "90s";
          disableMetricsLookup = false;
        };
        isDefault = false;
      }
      {
        # The VictoriaMetrics plugin
        name = "VictoriaLogs";
        type = "victoriametrics-logs-datasource";
        uid = "victorialogs";
        access = "proxy";
        editable = true;
        url = "http://127.0.0.1:9428";
        basicAuth = false;
        isDefault = false;
        jsonData.derivedFields = [
          {
            "datasourceUid" = "victoriatraces";
            "matcherType" = "label";
            "matcherRegex" = "trace_id";
            "name" = "TraceID";
            "url" = "$${__value.raw}";
          }
        ];
      }
      {
        name = "VictoriaTraces";
        type = "jaeger";
        uid = "victoriatraces";
        access = "proxy";
        editable = true;
        url = "http://127.0.0.1:10428/select/jaeger";
        basicAuth = false;
        jsonData = {
          tracesToLogs.datasourceUid = "victorialogs";
          nodeGraph.enabled = true;
        };
        isDefault = false;
      }
    ];
  };
}
