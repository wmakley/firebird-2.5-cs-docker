REPO := wmakley/firebird-2.5-cs
TAG := latest

# Build the image locally
image:
	docker build . -t ${REPO}:${TAG}

# Push the built image to docker hub
release: image
	docker push ${REPO}:${TAG}

# Explore the built image using bash with all services running
test: image volume
	docker run --rm -itv $(shell pwd)/volume:/firebird -p 3050:3050 -e ISC_PASSWORD=test -e LIMIT_HOST_ACCESS_TO_VOLUME=false --name fb-2.5-cs-test ${REPO}:${TAG} /sbin/my_init -- bash

volume:
	mkdir $@
