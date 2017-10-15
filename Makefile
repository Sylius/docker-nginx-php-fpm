include .stub/*.mk

# Define variables, export them and include them usage-documentation
$(eval $(call defw,NS,sylius))
$(eval $(call defw,REPO,nginx-php-fpm))
$(eval $(call defw,VERSION,latest))

# Targets
.PHONY: build
build:: ##@Docker Build the Sylius application image
	docker build \
		-f Dockerfile \
		-t $(NS)/$(REPO):$(VERSION) \
		.
