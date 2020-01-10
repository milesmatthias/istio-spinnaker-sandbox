IMG=milesmatthias/readiness-ruby-test

build:
	docker build -t $(IMG):latest .

release: build
	docker push $(IMG):latest
