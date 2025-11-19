{...}:
{
  virtualisation.oci-containers.containers.httpbin = {
    autoStart = true;
    image = "mccutchen/go-httpbin";
    extraOptions = [ "--network=kong" ];
    ports = [
      "127.0.0.1:8080:8080/tcp"
    ];
  };
}
