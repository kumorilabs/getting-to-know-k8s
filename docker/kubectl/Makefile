.PHONY: all build

DOCKER  = docker
REPO    = smesch
NAME    = kubectl
VERSION = 1.7.6

all: build

build:
	$(DOCKER) build -t $(NAME) --rm .

tag: build
	$(DOCKER) tag $(NAME) $(REPO)/$(NAME):$(VERSION)

push: tag
	$(DOCKER) push $(REPO)/$(NAME):$(VERSION)

latest: push
	$(DOCKER) tag $(NAME) $(REPO)/$(NAME):latest
	$(DOCKER) push $(REPO)/$(NAME):latest