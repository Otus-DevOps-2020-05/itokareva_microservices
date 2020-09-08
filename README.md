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

   

  
 	

 
