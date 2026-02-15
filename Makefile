package:
	create-dmg \
		--volname "Zunda Converter" \
		--app-drop-link 600 185 \
		--icon-size 100 \
		--icon "ZundaConverter.app" 200 190 \
		--window-pos 200 120 \
		--window-size 800 400 \
		ZundaConverter.dmg ./build
