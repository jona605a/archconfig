function gpu-driver-links --description 'Build a dir of symlinks to the host NVIDIA driver libs, safe to append to LD_LIBRARY_PATH inside a Nix shell. Prints the dir. Pass -f to force a rebuild.'
    set -l dir $XDG_CACHE_HOME
    test -n "$dir"; or set dir $HOME/.cache
    set dir $dir/gpu-driver-links

    # Keep this dir as SMALL as possible. Every lib in it outranks the
    # DT_RUNPATH of every Nix binary in the shell (LD_LIBRARY_PATH always wins
    # over RUNPATH, appended or not), so anything we expose replaces Nix's copy
    # of the same soname. Arch libs built against a newer glibc than the
    # devshell's then die with e.g.
    #   undefined symbol: __pointer_chk_guard, version GLIBC_PRIVATE
    #   version `GLIBC_2.44' not found
    #
    # So: NVIDIA only. NVIDIA's libs are built against ancient glibc on purpose
    # and are safe; their only outside deps are the X11/xcb client libs.
    # Mesa (the AMD iGPU) is deliberately left out: RADV needs Arch's libLLVM,
    # which needs Arch's glibc, so it can't load in the devshell anyway -- and
    # exposing it dragged in libz/libzstd/libicu/libncursesw/... for nothing.
    set -l keep_external '^lib(X11|X11-xcb|Xext|Xau|Xdmcp|xcb(-[a-z0-9]+)?)\.so'
    set -l excl '^(libc|libm|libdl|libpthread|librt|libresolv|libutil|libanl|libthread_db|libgcc_s|libstdc\+\+|libnss_[^.]*|ld-linux.*)\.so'
    set -l icd /usr/share/vulkan/icd.d/nvidia_icd.json

    if not pacman -Q nvidia-utils >/dev/null 2>&1
        echo "gpu-driver-links: nvidia-utils not installed; no driver libs to link" >&2
        return 1
    end

    # Rebuild only when the driver or its deps change.
    set -l stamp (pacman -Q nvidia-utils libx11 libxext libxcb 2>/dev/null | string join ' ')
    if test "$argv[1]" != -f; and test -f $dir/.stamp
        if test "$(cat $dir/.stamp)" = "$stamp"
            echo $dir
            return 0
        end
    end

    # 1. Everything nvidia-utils ships as a shared lib. Covers the libs the
    #    driver dlopens (rtcore, glvkspirv, allocator, ...) that no ldd sees.
    #    Minus the confidential-computing pkcs11 module, which links Arch's
    #    openssl/zlib/zstd/brotli.
    set -l libs (pacman -Qlq nvidia-utils | string match -r '^/usr/lib/lib[^/]*\.so[.0-9]*$' |
                 string match -rv '/libnvidia-pkcs11')

    # 2. Outside deps, restricted to X11/xcb client libs. Link-time ones via
    #    ldd, plus the ones the driver dlopens (xcb-glx/dri3/present/sync,
    #    X11-xcb), found by letting the HOST loader bring up just the NVIDIA
    #    ICD. Without those, libGLX_nvidia loads but exposes no
    #    vkCreateInstance and the GPU silently vanishes.
    set -l ext
    for l in $libs
        set -a ext (env -u LD_LIBRARY_PATH ldd $l 2>/dev/null | string match -gr '=> (/usr/lib/\S+)')
    end
    if test -x /usr/bin/vulkaninfo
        set -a ext (env -u LD_LIBRARY_PATH VK_DRIVER_FILES=$icd VK_LOADER_LAYERS_DISABLE='VK_LAYER_MESA_*' \
                    LD_DEBUG=libs /usr/bin/vulkaninfo --summary 2>&1 >/dev/null |
                    string match -gr 'calling init: (/usr/lib/\S+)')
    else
        echo "gpu-driver-links: no vulkaninfo to probe with, using a static xcb list" >&2
        set -a ext /usr/lib/lib{X11-xcb.so.1,xcb-dri3.so.0,xcb-glx.so.0,xcb-present.so.0,xcb-sync.so.1}
    end
    for l in $ext
        string match -qr $keep_external -- (path basename $l); and set -a libs $l
    end

    set -l tmp $dir.new.$fish_pid
    rm -rf $tmp $dir
    mkdir -p $tmp
    for lib in (printf '%s\n' $libs | sort -u)
        test -e $lib; or continue
        set -l base (path basename $lib)
        string match -qr $excl -- $base; and continue
        ln -sf $lib $tmp/$base
    end
    # NVIDIA's implicit Vulkan layers only, for VK_IMPLICIT_LAYER_PATH, so the
    # loader never tries Mesa's (whose libs aren't, and can't be, in here).
    mkdir $tmp/implicit_layer.d
    for j in (pacman -Qlq nvidia-utils | string match -r '^/usr/share/vulkan/implicit_layer\.d/.*\.json$')
        ln -sf $j $tmp/implicit_layer.d/
    end
    echo "$stamp" >$tmp/.stamp
    mv $tmp $dir

    set -l n (count (path filter $dir/*.so*))
    if test $n -eq 0
        echo "gpu-driver-links: warning -- linked 0 driver libs; GPU will not be available" >&2
    else
        echo "gpu-driver-links: linked $n host driver libs into $dir" >&2
    end

    echo $dir
end
