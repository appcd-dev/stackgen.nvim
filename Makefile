fmt:
	echo "===> Formatting code"
	stylua lua/ plugin/ --config-path .stylua.toml

lint:
	echo "===> Linting code"
	luacheck lua/ plugin/ --config .luacheckrc

pr-ready: fmt lint
