function worknix --wraps='cd ~/work/nobodywho/; nix develop' --description 'cd to nobodywho and enter the nix devshell, with host GPU drivers usable'
    cd ~/work/nobodywho/

    # The devshell needs Arch's NVIDIA Vulkan driver (llama.cpp falls back to
    # CPU without it), but Nix's ld.so neither searches /usr/lib nor reads
    # /etc/ld.so.cache, so it can't find the lib the ICD manifest names.
    #
    # Putting /usr/lib on LD_LIBRARY_PATH -- as this function used to -- fixes
    # that and breaks everything else: LD_LIBRARY_PATH outranks DT_RUNPATH, so
    # Nix binaries pick up Arch's libc.so.6 (and friends) and die with
    #   undefined symbol: __pointer_chk_guard, version GLIBC_PRIVATE
    # Hence a narrow dir of NVIDIA libs only (see gpu-driver-links). It's
    # appended, but note that only orders it after Nix's vulkan-loader entry;
    # it still shadows RUNPATH, which is why the dir must stay small.
    #
    # VK_DRIVER_FILES pins the loader to the NVIDIA ICD so it doesn't try
    # Arch's Mesa/RADV driver for the AMD iGPU, which needs a newer glibc than
    # the devshell and so never loaded here anyway. VK_IMPLICIT_LAYER_PATH
    # likewise limits implicit layers to NVIDIA's (otherwise: "cannot open
    # libVkLayer_MESA_device_select.so" on every Vulkan start).
    set -l gpulibs (gpu-driver-links)

    if test -z "$gpulibs"
        echo "worknix: no GPU driver links; the devshell will run on CPU" >&2
        nix develop $argv --command fish
    else
        nix develop $argv --command fish -C "
            set -gx LD_LIBRARY_PATH \$LD_LIBRARY_PATH $gpulibs
            set -gx VK_DRIVER_FILES /usr/share/vulkan/icd.d/nvidia_icd.json
            set -gx VK_IMPLICIT_LAYER_PATH $gpulibs/implicit_layer.d"
    end
end
