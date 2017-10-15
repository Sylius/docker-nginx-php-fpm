include .stub/*.mk

# Define variables, export them and include them usage-documentation
$(eval $(call defw,NS,sylius))
$(eval $(call defw,REPO,nginx-php-fpm))
$(eval $(call defw,VERSION,latest))

# Targets
.PHONY: build
build:: ##@Docker Build the Sylius-ready image
	docker build \
		-f Dockerfile \
		-t $(NS)/$(REPO):$(VERSION) \
		.

.PHONY: run
run:: ##@Docker Run a container from this image
	docker run \
		--name=sylius-nginx-php-fpm \
		--rm \
		$(NS)/$(REPO):$(VERSION)
