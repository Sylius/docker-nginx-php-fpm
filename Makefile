include .stub/*.mk

# Define variables, export them and include them usage-documentation

# Targets
.PHONY: build
build:: ##@Docker Build the Sylius application image
	docker build \
		-f Dockerfile \
		.
