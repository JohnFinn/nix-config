{
  ripdrag,
  writeShellApplication,
}:
writeShellApplication
{
  name = "ripdrag-singleton";
  runtimeInputs = [ripdrag];
  text =
    /*
    bash
    */
    ''
      stdin=/tmp/ripdrag-singleton-stdin

      function server() {
        touch $stdin
        # shellcheck disable=SC2064
        trap "rm -f $stdin" EXIT
        tail -f $stdin | ripdrag --from-stdin --all
      }

      if [[ -f $stdin ]]
      then echo "$@" >> $stdin
      else
        server &
        echo "$@" >> $stdin
      fi
    '';
}
