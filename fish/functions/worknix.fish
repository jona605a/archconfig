function worknix --wraps='cd ~/work/nobodywho/nobodywho/; nix develop' --description 'cd to nobodywho and enter the nix devshell, with host GPU drivers usable'
    cd ~/work/nobodywho/nobodywho/

    # The devshell needs Arch's Vulkan drivers (llama.cpp falls back to CPU
    # without them), but Nix's ld.so neither searches /usr/lib nor reads
    # /etc/ld.so.cache, so it can't find the libs the ICD manifests name.
    #
    # Putting /usr/lib on LD_LIBRARY_PATH -- as this function used to -- fixes
    # that and breaks everything else: LD_LIBRARY_PATH outranks DT_RUNPATH, so
    # Nix binaries pick up Arch's libc.so.6 and die with
    #   undefined symbol: __pointer_chk_guard, version GLIBC_PRIVATE
    # since glibc 2.43 moved that symbol into ld.so. Hence a narrow symlink dir
    # of driver libs only, APPENDED so Nix's own libs keep priority.
    set -l gpulibs (gpu-driver-links)

    if test -z "$gpulibs"
        echo "worknix: no GPU driver links; the devshell will run on CPU" >&2
        nix develop $argv --command fish
    else
        nix develop $argv --command fish -C "set -gx LD_LIBRARY_PATH \$LD_LIBRARY_PATH $gpulibs"
    end
end
