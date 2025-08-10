nvidia: export __NV_PRIME_RENDER_OFFLOAD=1
nvidia: export __GLX_VENDOR_LIBRARY_NAME=nvidia
nvidia:
	@zig build -Doptimize=ReleaseFast run

intel:
	@zig build -Doptimize=ReleaseFast run
