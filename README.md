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
