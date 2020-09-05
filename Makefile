COMMENT_VERSION = 1.0
POST_VERSION = 1.0
UI_VERSION = 1.0
PROMETHEUS_VERSION = 1.0
CURRENT_VERSION = 1.0
BLACKBOX_VERSION = 1.0
CURRENT_USERNAME = itokareva
build: comment_build post_build ui_build prometheus_build blackbox-exporter
VPATH = src:monitoring
comment_build: comment
	docker build -t $(CURRENT_USERNAME)/comment:$(COMMENT_VERSION) $^
post_build: post-py
	docker build -t $(CURRENT_USERNAME)/post:$(POST_VERSION) $^
ui_build: ui
	docker build -t $(CURRENT_USERNAME)/ui:$(UI_VERSION) $^
prometheus_build: prometheus
	docker build -t $(CURRENT_USERNAME)/prometheus:$(PROMETHEUS_VERSION) $^
blackbox_build: blackbox-exporter
	docker build -t $(CURRENT_USERNAME)/blackbox-exporter:$(BLACKBOX_VERSION) $^
#build: comment_build post_build ui_build prometheus_build
#	docker build -t $(CURRENT_USERNAME)/$^:$(CURRENT_VERSION) $^
comment_push: comment
	docker push $(CURRENT_USERNAME)/comment:$(COMMENT_VERSION)
post_push: post-py 
	docker push $(CURRENT_USERNAME)/post:$(POST_VERSION)
ui_push: ui
	docker push $(CURRENT_USERNAME)/ui:$(UI_VERSION)
prometheus_push: prometheus
	docker push $(CURRENT_USERNAME)/prometheus:$(PROMETHEUS_VERSION)
blackbox_push: blackbox-exporter
	docker push $(CURRENT_USERNAME)/blackbox-exporter:$(BLACKBOX_VERSION)
push: comment_push post_push ui_push prometheus_push blackbox-exporter




