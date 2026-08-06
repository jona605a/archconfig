function gpu-driver-links --description 'Build a dir of symlinks to the host GPU driver libs, safe to append to LD_LIBRARY_PATH inside a Nix shell. Prints the dir. Pass -f to force a rebuild.'
    set -l dir $XDG_CACHE_HOME
    test -n "$dir"; or set dir $HOME/.cache
    set dir $dir/gpu-driver-links

    # Libs we must NEVER shadow: everything glibc ships, plus the C++/GCC runtime.
    #
    # Nix binaries run under Nix's ld.so, and LD_LIBRARY_PATH outranks their
    # DT_RUNPATH -- so exposing Arch's libc.so.6 here kills every dynamically
    # linked program in the shell with
    #   undefined symbol: __pointer_chk_guard, version GLIBC_PRIVATE
    # (the symbol moved into ld.so in glibc 2.43; Nix's ld.so is older).
    # Keeping this set narrow is the whole point: exposing all of /usr/lib also
    # breaks e.g. gradle, because Arch's libgnutls wants GLIBC_2.43.
    set -l excl '^(libc|libm|libdl|libpthread|librt|libresolv|libutil|libanl|libthread_db|libgcc_s|libstdc\+\+|libnss_[^.]*|ld-linux.*)\.so'

    # Rebuild only when the host drivers change.
    set -l stamp (pacman -Q mesa nvidia-utils vulkan-icd-loader 2>/dev/null | string join ' ')
    test -n "$stamp"; or set stamp (stat -c '%Y' /usr/lib /usr/share/vulkan/icd.d 2>/dev/null | string join ' ')
    if test "$argv[1]" != -f; and test -f $dir/.stamp
        set -l old (cat $dir/.stamp)
        if test "$old" = "$stamp"
            echo $dir
            return 0
        end
    end

    # Probe: let the HOST loader load every driver the system advertises, and
    # record what it actually pulled in. Derived beats hand-listed -- the NVIDIA
    # stack dlopens libs no ldd can see (glvkspirv, rtcore, allocator, xcb-glx),
    # and without them libGLX_nvidia loads but exposes no vkCreateInstance, so
    # the GPU silently vanishes. Re-probing means driver updates need no edits here.
    # LD_LIBRARY_PATH is cleared so the probe can't be skewed by a Nix shell.
    set -l libs
    if test -x /usr/bin/vulkaninfo
        set libs (env -u LD_LIBRARY_PATH LD_DEBUG=libs /usr/bin/vulkaninfo --summary 2>&1 >/dev/null |
                  string match -gr 'calling init: (/usr/lib/\S+)' | sort -u)
    end

    if test -z "$libs"
        # No probe available (vulkan-tools missing?). Fall back to the link-time
        # closure of the advertised drivers plus the families they dlopen.
        echo "gpu-driver-links: no vulkaninfo to probe with, falling back to a static list" >&2
        for j in /usr/share/vulkan/icd.d/*.json
            for lp in (cat $j | string replace -rf '.*"library_path"[^"]*"([^"]+)".*' '$1')
                string match -q '/*' -- $lp; and set -a libs $lp; or set -a libs /usr/lib/$lp
            end
        end
        for d in $libs
            test -e $d; and set -a libs (ldd $d 2>/dev/null | string match -gr '=> (/usr/lib/\S+)')
        end
        set -a libs (find /usr/lib -maxdepth 1 \( -name 'libnvidia-*' -o -name 'libcuda.so*' \
            -o -name 'libdrm*' -o -name 'libVkLayer_*' -o -name 'libxcb*' -o -name 'libX11*' \
            -o -name 'libdbus-1.so*' -o -name 'libsystemd.so*' -o -name 'libEGL*' -o -name 'libGL*' \) 2>/dev/null)
    end

    set -l tmp $dir.new.$fish_pid
    rm -rf $tmp $dir
    mkdir -p $tmp
    for lib in $libs
        test -e $lib; or continue
        set -l base (path basename $lib)
        string match -qr $excl -- $base; and continue
        ln -sf $lib $tmp/$base
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
