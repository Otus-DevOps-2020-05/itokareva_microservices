COMMENT_VERSION = 1.0
POST_VERSION = 1.0
UI_VERSION = 1.0
PROMETHEUS_VERSION = 1.0
CURRENT_VERSION = 1.0
BLACKBOX_VERSION = 1.0
ALERTMANAGER_VERSION = 1.0
CURRENT_USERNAME = itokareva
# BUILD
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
alertmanager_build: alertmanager 
	docker build -t $(CURRENT_USERNAME)/alertmanager:$(ALERTMANAGER_VERSION) $^
# PUSH	
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
alertmanager_push: alertmanager
	docker push $(CURRENT_USERNAME)/alertmanager:$(ALERTMANAGER_VERSION)
push: comment_push post_push ui_push prometheus_push blackbox_push alertmanager_push




