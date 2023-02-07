.NOTPARALLEL:
.PHONY: default format format-fix format-check

# This is the default target
default:
	$(error You must provide a target)

FORMATTER_COMMAND = JULIA_LOAD_PATH="@" julia --startup-file=no --project=.format .format/format.jl

format: format-fix

format-fix:
	julia --startup-file=no --project=.format -e 'import Pkg; Pkg.instantiate(); Pkg.precompile()'
	$(FORMATTER_COMMAND) fix

format-check:
	julia --startup-file=no --project=.format -e 'import Pkg; Pkg.instantiate(); Pkg.precompile()'
	$(FORMATTER_COMMAND) check
