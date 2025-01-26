{
  pkgs,
  lib,
  config,
  ...
} @ inputs: {
  options = {
    jsonField = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          key = lib.mkOption {type = lib.types.str;};
          value = lib.mkOption {type = lib.types.str;};
        };
      });
    };
  };

  config = lib.mkIf (config.jsonField != {}) {
    home.activation.json-file = inputs.lib.hm.dag.entryAfter ["writeBoundary"] (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (filename: attrs: ''
          ${pkgs.jq}/bin/jq '${attrs.key} = ${attrs.value}' < ${filename} | run ${pkgs.moreutils}/bin/sponge ${filename}
        '')
        config.jsonField)
    );
  };
}
