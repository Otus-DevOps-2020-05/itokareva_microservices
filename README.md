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
