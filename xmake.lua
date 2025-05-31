--
--  Copyright (C) 2025 NullPotOS Project
--  Follow MIT License
--

set_project("linaix-os")

set_version("0.0.1")

add_rules("mode.debug", "mode.release")

add_requires("limine v9.x-binary", {system = false})

target("kernel")
        set_kind("binary")
        set_default(false)
        set_toolchains("clang")

        add_cxxflags("-target x86_64-freestanding -fuse-ld=lld")
        add_ldflags("-target x86_64-freestanding")

        add_cxxflags("-mno-80387", "-mno-mmx", "-mno-sse", "-mno-sse2")
        add_cxxflags("-mno-red-zone", "-msoft-float", "-flto")
        add_ldflags("-T kernel/arch/x86/linker.lds", "-nostdlib", "-fuse-ld=lld")
 
        before_build(function (target)
            local hash = try { function()
                local result = os.iorun("git rev-parse --short HEAD")
                return result and result:trim()
            end }
            if hash then target:add("defines", "GIT_VERSION=\""..hash.."\"") end
        end)

        add_includedirs("includes")
        
        add_files("kernel/**.cpp")

target_end()

target("iso")
        set_kind("phony")
        add_deps("kernel")
        add_packages("limine")
        set_default(true)

        on_build(function (target)
            import("core.project.project")

            local iso_dir = "$(buildir)/iso_dir"

            local limine_src = target:pkg("limine"):installdir()
            local limine_src = limine_src.."/share/limine"

            os.cp(limine_src.."/BOOTX64.EFI", iso_dir.."/EFI/BOOT/BOOTX64.EFI")
            os.cp(limine_src.."/BOOTAA64.EFI", iso_dir.."/EFI/BOOT/BOOTAA64.EFI")
            os.cp(limine_src.."/BOOTRISCV64.EFI", iso_dir.."/EFI/BOOT/BOOTRISCV64.EFI")
            os.cp(limine_src.."/BOOTLOONGARCH64.EFI", iso_dir.."/EFI/BOOT/BOOTLOONGARCH64.EFI")
            os.cp(limine_src.."/limine-bios.sys", iso_dir.."/limine-bios.sys")
            os.cp(limine_src.."/limine-bios-cd.bin", iso_dir.."/limine-bios-cd.bin")
            os.cp(limine_src.."/limine-uefi-cd.bin", iso_dir.."/limine-uefi-cd.bin")
    
            os.cp("assets/boot/limine.conf", iso_dir.."/limine.conf")

            local kernel = project.target("kernel")
            os.cp(kernel:targetfile(), iso_dir.."/linaix-os/kernel.elf")

            local iso_file = "$(buildir)/linaix-os.iso"
            os.run("xorriso -as mkisofs "..
                "-R -r -J -b limine-bios-cd.bin "..
                "-no-emul-boot -boot-load-size 4 -boot-info-table "..
                "-hfsplus -apm-block-size 2048 "..
                "--efi-boot limine-uefi-cd.bin "..
                "-efi-boot-part --efi-boot-image --protective-msdos-label "..
                "%s -o %s", iso_dir, iso_file)

            os.run("limine bios-install "..iso_file)
            print("iso image created at: %s", iso_file)
    end)
target_end()

target("run")
        set_kind("phony")
        add_deps("iso")
        set_default(true)

        on_run(function (target)
            import("core.project.config")
            local disk_template = "if=none,format=raw,id=disk,file="
            local flags = {
                "-enable-kvm",
                "-M", "q35", "-cpu", "Haswell,+x2apic,+avx", "-smp", "4",
                "-serial", "stdio", "-m","1024M",
                "-audiodev", "sdl,id=audio0",
                "-device", "sb16,audiodev=audio0",
                "-net","nic,model=pcnet","-net","user",
                "-drive", "if=pflash,format=raw,file=assets/firmware/ovmf-code.fd",
                "-cdrom", config.buildir().."/linaix-os.iso",
            }
            os.execv("qemu-system-x86_64", flags)
        end)
    target_end()

package("limine")
    set_kind("binary")
    set_urls("https://github.com/limine-bootloader/limine.git")
    
    on_install(function (package)
        local prefix = "PREFIX="..package:installdir()
        import("package.tools.make").make(package)
        import("package.tools.make").make(package, {"install", prefix})
    end)
package_end()