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
	docker run --rm -itv $(shell pwd)/volume:/firebird -p 3050:3050 -e ISC_PASSWORD=test --name fb-test ${REPO}:${TAG} /sbin/my_init -- bash

volume:
	mkdir $@
