.PHONY: build clean

build:
	@ASEPRITE_SHA="$(or $(ASEPRITE_SHA),main)" bash build.sh

clean:
	rm -rf output .image-id
	podman rmi aseprite-builder 2>/dev/null || true
