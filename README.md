# itokareva_microservices
itokareva microservices repository

# Домашняя работа 17

  Технологии контейнеризации. Введение в docker.

1) Установлены Docker, docker-compose, docker-machine
2) Выполнено задание со (*) о сравнении команд docker inspect  <u_container_id> и <u_image_id>
   результат в файле dockermonolith/docker-1.log
3) Создан docker-monolith/Dockerfile, собран образ reddit:latest (latest - tag), запущен контейнер с этим образом,
   проверен результат в браузере
4) Зарегистрировалась на Docker hub
5) Загрузка образа на Docker hub itokareva/otus-reddit:1.0

   Задание со (*)

1) Создан образ с "голым" Ubuntu с помощью packer
2) Созданы виртуальные машины (counter=2)
3) Зоздан playbook infra/playbooks/create_docker_host.yml для запуска docker-machine на локальной машине, переключение env и запуск докера из созданного образа.
Все с использованием динамического инвентори inventory.sh
4) все рабочие файлы в папке docker-monolith/infra

# Домашняя работа 18

  Docker-образы. Микросервисы

1) Разбили наше приложение на 4 компонента:
   - post-py - сервис отвечающий за написание постов
   - comment - сервис отвечающий за написание комментариев
   - ui - веб-интерфейс, работающий с другими сервисами
   - микросервис с mongo
2) Создали Dockerfile для post-py, comment, ui.
3) Построили образы. Образ mongo скачали с Docker hub
4) Создали сеть приложения reddit
5) Запустили наши контейнеры:

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --env POST_DATABASE_HOST=post_db --network=reddit --network-alias=post itokareva/post:1.0
docker run -d --env COMMENT_DATABASE_HOST=comment_db --network=reddit --network-alias=comment itokareva/comment:1.0
docker run -d --env COMMENT_SERVICE_HOST=comment --env POST_SERVICE_HOST=post --network=reddit -p 9292:9292 itokareva/ui:1.0

6) Приложение работает

Задание со (*)

docker run -d --network=reddit --network-alias=post_db1 --network-alias=comment_db1 mongo:latest
docker run -d --env POST_DATABASE_HOST=post_db1 --network=reddit --network-alias=post1 itokareva/post:1.0
docker run -d --env COMMENT_DATABASE_HOST=comment_db1 --network=reddit --network-alias=comment1 itokareva/comment:1.0
docker run -d --env COMMENT_SERVICE_HOST=comment1 --env POST_SERVICE_HOST=post1 --network=reddit -p 9292:9292 itokareva/ui:1.0

Задание со (**)

7) Улучшаем образ микросервиса ./ui/Dockerfile
   Образ на основе alpine и с очисткой компонентов, которые нужны были для сборки в файле: ./ui/Dockerfile.1

REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
itokareva/ui            4.0                 b2af1a600f5a        53 minutes ago      86.7MB
itokareva/ui            3.0                 a6b32ca484df        32 hours ago        252MB
itokareva/ui            2.0                 13b30259657a        32 hours ago        449MB
itokareva/ui            1.0                 c6b1da16bb68        40 hours ago        770MB

8) Подключили volume с именем  reddit_db к нашей бд mongo

9) теперь состояние нашей базы сохраняется в volume и посты не пропадают после перезагрузки сервисов

# Домашняя работа 18

1) Протестирована работа в сети docker none, host, bridge
2) Запущены микросервисы проекта с использованием сети bridge c использованием сетевых алиасов: указываем --network-alias при старте контейнеров
3) Протестирован запуск проекта в 2-х bridge сетях: back_net и front_net
-  для корректной работы приложения контейнеры post и comment были помещены в обе сети. Иначе контейнеры из соседних сетей не будут доступны как в DNS, 
так и  для взаимодействия по сети.  
5) Изучен сетевой стек Linux при работе микросервисов с использованием сети bridge
6) Реализована сборка и запуск микросервисов проекта с использованием docker-compose:
   - создан конфигурационный файл docker-compose.yml, строящий и запускающий наши микросервисы
   - использована интерполяция и параметризация с использованием файла переменных .env (env_file=.env в docker-compose.yml), если задать с другим именем,
     например reddit.env, to docker-compose нужно запускать docker-compose --project-name reddit_project --env-file reddit.env up -d)
   - параметризованы: каталог на docker hub(USERNAME), порт и протокол  публикации сервиса ui, версии сервисов 
   - чтобы docker-compose сущности имели в качестве префикса имя проекта используем:
      a) ключ при старте:
         docker-compose --project-name reddit_project up -d (docker-compose ps --project-name reddit_project)
      b) задаем переменную среды:
         export COMPOSE_PROJECT_NAME=reddit_project
      c) добавляем COMPOSE_PROJECT_NAME=reddit_project  в файл параметров
      d) иначе будет использоваться в качестве префикса название каталога проекта

Задание со (**)

Создан файл docker-compose.override.yml, позволяющий запускать puma для руби приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2)  

# Домашняя работа 19   

Устройство Gitlab CI. Устройство Gitlab CI. Построение процесса Построение процесса непрерывной поставки 

1) Cоздана YC-виртуальная машина gitlab-ci-vm1 с помощью terraform
2) С помощью gitlab-ci/infra/playbooks/create_docker_host.yml устанавливаем docker на виртуальной машине:
ansible-playbook playbooks/create_docker_host.yml -t create_docker
3) устанавливаем docker-compose на ВМ:
ansible-playbook playbooks/install_docker_compose.yml
4) запускаем gitlab в docker-контейнере, запускаем контейнер с gitlub-runner и регистрируем его (*). Все с помощью play-book docker_compose.yml:
ansible-playbook playbooks/docker_compose.yml -t web  -vvv
5) Настраиваем pipelines:
   - запуск приложения reddit в этапе pipeline в этапе пайплайна build (*) 
   - настроена интеграция в slack на исменеие статуса pipeline

# Домашняя работа 20
Введение в Введение в мониторинг. Системы мониторинг. Системы мониторинга    

1) Знакомство с prometheus. Запуск prometheus внутри Docker-контейнера.
2) Знакомство с web-интерфейсом.
3) Конфигурация prometheus на мониторинг наших микросервисов comment, post, ui.
В коде микросервисов есть healthcheck-и для проверки работоспособности приложения.
4) Добавляем в docker-compose.yml новый сервис prometheus. Запускаем сервисы приложения reddit и prometheus в docker-контейнерах.
5) Мониторим состояния микросервисов через web-интерфейс.
6) Добавляем сервис Node exporter в docker-compose.yml для сбора метрик хоста.
7) Получим информацию об использовании CPU через web-интерфейс.
8) (*) Добавила экспортер elarasu/mongodb_exporter@sha256:6d58466a866b25cff5fd19617790d188ebba2474af9e02bb8accb85b5147b69b для мониторинга MongoDB.
   В Docker hub у образа был тэг latest, но он работал стабильно и я его зафиксировала через уникальный референс sha256:6d58466a866b25cff5fd19617790d188ebba2474af9e02bb8accb85b5147b69b.
9) (*) Добавила Cloudprober, который так же поднимается как сервис в docker-контейнере и работает как blackbox экспортер.
10) (*) создан Makefile, который позволяет собирать и регистрировать на Docker hub образы наших сервисов приложения, prometheus и blackbox экспортера.
     make blackbox_build # сборка образ для конкретного микросервиса
     make build # сборка образов всех микросервисов
     make blackbox_push # регистрация образа конкретного микросервиса на docker hub
     make push # регистрация всех микросервисов на docker hub  
 
# Домашняя работа 21

Мониторинг Мониторинг приложения и приложения и инфраструктуры 

1) Наблюдение за состоянием Docker контейнеров c помощью cAdvisor.
Все метрики начинаются с префикса container_. По пути /metrics все собираемые метрики публикуются для сбора Prometheus.
Проверено, что метрики собираются в prometheus.
2) Добавлен новый сервис GRAFANA Grafana для визуализации данных из Prometheus.
3) Импортирован дашборд "Docker and system monitoring" (DockerMonitoring.json) с сайта уже созданных официальных и комьюнити дашбордов https://grafana.com/grafana/dashboards
4) Добавлен мониторинг post-сервиса в prometheus
5) Созданы 2 дашборда в графане для мониторинга сервиса ui с использованием метрик prometheus типа counter и histogram (ui_service_monitoring-1599145568713.json).
6) Для мониторинга бизнес-логики построены 2 дашборда: post_count, comment_count (Business_Logic_Monitoring-1599146817349.json).
7) Настроен Alertmanager с отправкой нотификаций в slack
8) Добавлены alert rulls в prometheus с правилом срабатывния, когда один из сервисов в статусе down. Соббщения о падении сервиса приходят в slack.

Задание (*)
1) Поднят docker swarm (init + docker swarm join waker)
   docker swarm init --advertise-addr ip-host1
   docker swarm join-token worker
   на другой машине docker swarm join --token SWMTKN-1-24b7t7txn64so15uh9bz25runesavsyck261vxghzxuildpplh-c0yl5p3qbrw4yu9tdojq9ed6t ip-host1:2377
   
docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
ie0liejtgkp58whk1d4q62ik3 *   docker-host1        Ready               Active              Leader              19.03.12
u9awln1b4iqjvcmim7uiqwbyt     itokareva-otus      Ready               Active                                  19.03.12

2) Запущены сервисы prometheus и grafana:

docker network create --driver overlay my-network

docker service create --replicas 1 --name my-grafana --publish published=3000,target=3000,protocol=tcp \ 
--mount source=appgrafana_data,target=/var/lib/grafana --env GF_SECURITY_ADMIN_USER=admin \
--env GF_SECURITY_ADMIN_PASSWORD=secret --network my-network grafana/grafana:5.0.0

docker service create --replicas 1 --name my-prometheus --publish published=9090,target=9090,protocol=tcp --network my-network \ 
itokareva/prometheus:2.0 image itokareva/prometheus:2.0

itokareva/prometheus:2.0 собран с новой конфигурацией (prometheus.yml.swarm)
	
добавлен:
---
global:
  scrape_interval: '5s'
  external_labels:
      monitor: 'codelab-monitor'

....
  - job_name: 'docker'
    static_configs:
      - targets:
        - 'ip-host:9323'  

3) построен дашборд(DockerMonitoring.json) для метрики engine_daemon_network_actions_seconds_count и создана сетевая нагрузка сервисом:

docker service create \
  --replicas 10 \
  --name ping_service \
  alpine ping docker.com

4) Реализован alert expr: histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m])) by (le))>0.05 с отправкой оповещений в slack.

Задание (**)

Реализовано автоматическое добавление источника данных и созданных в данном ДЗ дашбордов в графану;
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana:/etc/grafana/provisioning/

в файле docker/docker-compose-monitoring.yml. Все конфигурационные файлы в docker/grafana.
 
# Домашняя работа 24

Логирование и распределенная распределенная трассировка

1) Для логгирования докер контейнеров был поднят ElasticSearch-стэк:
- создан logging/ﬂuentd/Dockerfile и файл конфигурации logging/ﬂuentd/ﬂuent.conf
- построен образ для Fluentd, который будет использоваться в качестве Logstash (для аггрегации и трансформации данных)
- добавлены сервисы  ElasticSearch, Fluentd, kibana в файл docker/docker-compose-logging.yml
2) Настроена отправки логов во Fluentd для сервиса post
3) Работа в Кибане:
- Создание индекса
- Просмотр логов
- Создание фильтра по полям
3.1) Добавление фильтра во Fluentd (ﬂuent.conf) для сервиса post
- поиск по структурированным логам
3.2) Настройка отправки логов во Fluentd для сервиса ui
- Добавление фильтра во Fluentd (ﬂuent.conf) для сервиса ui: через регулярные выражения, с использованием одног и
комбинации Grok-шаблонов
- поиск по неструктурированным логам
3.3) Задание (*)

- создан grok-шаблон для строки лога like this:

service=ui | event=request | path=/new | request_id=87b830c0-f084-44b7-aaa3-08d2636836a8 | remote_addr=10.20.78.34 | method= POST | response_status=303
%{WORD:service} \| event=%{WORD:event} \| path=%{URIPATH:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IPV4:remote_addr} \| method= %{WORD:method} \| response_status=%{NUMBER:response_status}
Проверен сначала в grok-constructor, затем в Kibana:
{
  "_index": "fluentd-20200915",
  "_type": "access_log",
  "_id": "exknknQB-0GOdWUzjGn9",
  "_version": 1,
  "_score": null,
  "_source": {
    "timestamp": "2020-09-15T14:24:57.851648",
    "pid": "1",
    "loglevel": "INFO",
    "progname": "",
    "message": "service=ui | event=request | path=/ | request_id=2a4de9f3-536e-413c-a220-15c01f50e2a0 | remote_addr=10.20.78.34 | method= GET | response_status=200",
    "service": "ui",
    "event": "request",
    "path": "/",
    "request_id": "2a4de9f3-536e-413c-a220-15c01f50e2a0",
    "remote_addr": "10.20.78.34",
    "method": "GET",
    "response_status": "200",
    "@timestamp": "2020-09-15T14:24:57+00:00",
    "@log_name": "service.ui"
  },.....

4) Настрока распределенный трейсинга
- добавление сервиса zipkin в docker/docker-compose-logging.yml
- добавление для каждого сервиса в нашем приложении reddit параметр ZIPKIN_ENABLED (docker-compose.yml)
- просмотр трейсов в zipkin

Задание со (*)

Багнутая версия не работала сначала потому что у ui не было соединения с post и comment.
В Кибане было следующее сообщение:
{
  "_index": "fluentd-20200914",
  "_type": "access_log",
  "_id": "6LTBjnQBmKhcxZL4jQbk",
  "_version": 1,
  "_score": null,
  "_source": {
    "timestamp": "2020-09-14T22:34:42.927176",
    "pid": "1",
    "loglevel": "ERROR",
    "progname": "",
    "message": "Failed to read from Post service. Reason: Failed to open TCP connection to 127.0.0.1:4567 (Connection refused - connect(2) for \"127.0.0.1\" port 4567)",
    "service": "ui",
    "event": "show_all_posts",
    "request_id": "3c93d3e1-0272-4f4a-a0cd-a7df8b711a2c",
    "@timestamp": "2020-09-14T22:34:42+00:00",
    "@log_name": "service.ui"
  },
  "fields": {
    "@timestamp": [
      "2020-09-14T22:34:42.000Z"
    ],
    "timestamp": [
      "2020-09-14T22:34:42.927Z"
    ]
  },
  "sort": [
    1600122882000
  ]

Добавила в src_bug/bugged-code/ui/Dockerfile:
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
После этого приложение заработало.

Просмотр поста тормозил, потому что в текст /src_bug/bugged-code/ui/ui_app.rb был вставлен sleep(3):
@zipkin_span(service_name='post', span_name='db_find_single_post')
def find_post(id):
    start_time = time.time()
    try:
        post = app.db.find_one({'_id': ObjectId(id)})
    except Exception as e:
        log_event('error', 'post_find',
                  "Failed to find the post. Reason: {}".format(str(e)),
                  request.values)
        abort(500)
    else:
        stop_time = time.time()  # + 0.3
        resp_time = stop_time - start_time
        app.post_read_db_seconds.observe(resp_time)
        time.sleep(3)
        log_event('info', 'post_find',
                  'Successfully found the post information',
                  {'post_id': id})
        return dumps(post)

zipkin показывает эту задержку 3s:

get[3.096s]
/post/<id>[3.067s]
db_find_single_post[3.007s]

После того как отработал get ui логгирует сообщение в Кибану:

{
  "_index": "fluentd-20200914",
  "_type": "access_log",
  "_id": "WLTUjnQBmKhcxZL4zQdi",
  "_version": 1,
  "_score": null,
  "_source": {
    "timestamp": "2020-09-14T22:55:43.427264",
    "pid": "1",
    "loglevel": "INFO",
    "progname": "",
    "message": "Successfully showed the post",
    "service": "ui",
    "event": "show_post",
    "request_id": "eedf7f51-452f-4a87-8e9c-94a4de454f6c",
    "@timestamp": "2020-09-14T22:55:43+00:00",
    "@log_name": "service.ui"
  },
  "fields": {
    "@timestamp": [
      "2020-09-14T22:55:43.000Z"
    ],
    "timestamp": [
      "2020-09-14T22:55:43.000Z"
    ],
    "timestamp": [
      "2020-09-14T22:55:43.427Z"
    ]
  },
  "highlight": {
    "@log_name": [
      "@kibana-highlighted-field@service.ui@/kibana-highlighted-field@"
    ]
  },
  "sort": [
    1600124143000
  ]
}

# Домашняя работа 25

Введение в Kubernetes 

1) Вручную развернуты все компоненты Kubernetes, используя The Hard Way
2) При развертывании был применен параллельный запуск команд с использованием tmux 
3) Созданы файлы с Deployment манифестами приложений reddit в папке kubernetes/reddit 
4) Проверено, что по созданным deployment-ам (ui, post, mongo, comment) поды запускаются

   Задание со * 
   Создан Ansibleплейбук в папке kubernetes/ansible на установку управляющих компонентов Kubernetes из THW
(08-bootstrapping-kubernetes-controllers.md)  
 	

# Домашняя работа 26

Kubernetes. Запуск Kubernetes. Запуск кластера и кластера и приложения. Модель приложения. Модель безопасности 

1) Развернут Kubernetes локально с помощью утилиты minikube
2) Изучен файл манифеста ~/.kube/conﬁg: что такое кластер и контекст
3) Развернуто приложение reddit в minikube
4) Рассмотрены расширения (addons) в minikube на примере Dashboard
5) Знакомство с namespace
6) Развернут Kubernetes cluster в YC
7) Деплой всех компонентов приложения в namespace dev
8) Приложение работает нормально: посты создаются и сохраняются в БД
  
# Домашняя работа 27
Kubernetes. Networks,Storages.Storages.

1) Развернут кластер GCE/GKE
2) Знакомство с типами сервисов CluserIP, nodePort, LoadBalancer
3) знакомство с плагином kube-dns
4) Развертование приложения reddit с каждым из перечисденных видов сервисов
5) Развернут Igress и Ingress Controller
6) тестирование ingress в режиме "классический веб'
7) тестирование ingress в режиме "TLS Termination"
8) созданы и применены политики Network Policy для ограничения сетевого трафика  
9) протестированы различные типы хранилищ данных: 
- valume
- PersistentVolume
10) протестировано выделение ресурса хранилища по запросу PersistentVolumeClaim
11) создан StorageClass Fast и протестировано динамическое выделение ресурса хранилища 

# Домашняя работа 28
CI/CD в Kubernetes

1) Установлена клиентская часть helm - консольный клиент 
2) Установлена серверная часть helm - tiller (только до версии 1.13.1)
3) Разработаны chart-ы для компонент ui, post, comment 
4) Создан единый chart reddit, который объединяет наши компоненты, чтобы они друг друга видели
5) Загружены зависимости: появился файл requirements.lock с фиксацией зависимостей и архивы компонент в директории charts
6) Установлено приложение reddit в кластере kubernetes
7) Опробованы версии helm2 и helm3 для установки приложения reddit
8) Подготовлен GKE-кластер и установлен GitLab
9) Создана группа itokareva и 4 проекта: ui, post, comment и reddit
10) под каждый проект создан репозиторий
11) Настроен CI для проектов ui, post, comment. Использовали nginx-ingress, который был поставлен с gitlab вместо GCP 
12) Настроен развертывание приложения по коммиту в feature-бранч (не master) на вреенное окружение review
13) Добавлено удаление окружений по требованию (когда они больше не нужны
14) Настроен CD на статические окружения staging и production
15) Настроен pipeline comment с использованием helm2
16) Настроен pipeline post с использованием helm3
17) Синтаксис pipeline приведен в соответствие синтаксису Gitlab (.gitlab-ci.yml освобожден от секции auto_devops

Задание (*)

Связаны pipeline сборки (CI) с pipeline деплоя (CD) через триггер на стороне проекта deploy-reddit. 
Теперь сразу после релиза запускается деплой на окружение staging.

reddit_deploy_cd_start:
  stage: deploy
  only:
    - master
    - tags
  script:
    - echo "start pipline of the project reddit-deploy"
    - apk add -U curl 
    - "curl --request POST --form token=$TRIGGER_TOKEN --form ref=master http://gitlab-gitlab/api/v4/projects/1/trigger/pipeline"

, где 1 - id проекта reddit-deploy.
Секрет TRIGGER_TOKEN добавлен в CI/CD переменные проекта reddit-deploy

# Домашняя работа 29

Kubernetes. Kubernetes. Мониторинг и Мониторинг и логирование

## Мониторинг

1) Из Helm-чарта установлен ingress-контроллер nginx
2) Из Helm-чарта установлен prometheus
3) Создан файл custom_values.yml 
Основные отличия от values.yml:

- отключена часть устанавливаемых сервисов (pushgateway, alertmanager, kube-state-metrics)
- включено создание Ingress’а для подключения через nginx
- поправлен endpoint для сбора метрик cadvisor
- уменьшен интервал сбора метрик (с 1 минуты до 30 секунд)

4) Включен сервис kube-statemetrics для сбора информации о сущностях k8s (деплойменты, репликасеты, ...)
5) Вклечен nodeexporter для сбора метрик с нод
6) Использован механизм ServiceDiscovery для обнаружения приложений, запущенных в k8s
7) Изучено, как работает relabel_conﬁg

## Визуализация

1) Из Helm-чарта установлена grafana 
2) протестирован механизм templating’а

## Логгирование

Логирование в k8s будем выстраивать с помощью уже известного стека EFK:

- ElasticSearch - база данных + поисковый движок 
- Fluentd - шипер (отправитель) и агрегатор логов 
- Kibana - веб-интерфейс для запросов в хранилище и отображения их результатов
 	
 
