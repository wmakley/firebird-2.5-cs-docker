image:
	docker build . -t wmakley/firebird-2.5-cs:latest

release: image
	docker push wmakley/firebird-2.5-cs:latest
