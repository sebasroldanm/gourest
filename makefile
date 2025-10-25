.PHONY: help build up down restart logs shell composer artisan test migrate fresh cache-clear

APP_CONTAINER = gourest_app
MYSQL_CONTAINER = gourest_mysql
REDIS_CONTAINER = gourest_redis
NGINX_CONTAINER = gourest_nginx

help: ## Mostrar ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Construir contenedores
	docker-compose build --no-cache

up: ## Iniciar contenedores
	docker-compose up -d

down: ## Detener contenedores
	docker-compose down

down-volumes: ## Detener y eliminar volúmenes
	docker-compose down -v

restart: ## Reiniciar contenedores
	docker-compose restart

logs: ## Ver logs de todos los servicios
	docker-compose logs -f

logs-app: ## Ver logs de app
	docker-compose logs -f $(APP_CONTAINER)

logs-nginx: ## Ver logs de nginx
	docker-compose logs -f $(NGINX_CONTAINER)

logs-mysql: ## Ver logs de mysql
	docker-compose logs -f $(MYSQL_CONTAINER)

shell: ## Entrar al contenedor app
	docker-compose exec app sh

shell-root: ## Entrar al contenedor app como root
	docker-compose exec -u root app sh

composer: ## Ejecutar composer install
	docker-compose exec app composer install

composer-update: ## Actualizar dependencias
	docker-compose exec app composer update

composer-dump: ## Regenerar autoload
	docker-compose exec app composer dump-autoload

artisan: ## Ejecutar comando artisan (uso: make artisan CMD="migrate")
	docker-compose exec app php artisan $(CMD)

migrate: ## Ejecutar migraciones
	docker-compose exec app php artisan migrate

migrate-fresh: ## Migraciones frescas con seed
	docker-compose exec app php artisan migrate:fresh --seed

rollback: ## Rollback última migración
	docker-compose exec app php artisan migrate:rollback

seed: ## Ejecutar seeders
	docker-compose exec app php artisan db:seed

test: ## Ejecutar tests
	docker-compose exec app php artisan test

test-coverage: ## Ejecutar tests con coverage
	docker-compose exec app php artisan test --coverage

tinker: ## Ejecutar tinker
	docker-compose exec app php artisan tinker

cache-clear: ## Limpiar todos los caches
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

optimize: ## Optimizar aplicación para producción
	docker-compose exec app php artisan config:cache
	docker-compose exec app php artisan route:cache
	docker-compose exec app php artisan view:cache
	docker-compose exec app php artisan event:cache

optimize-clear: ## Limpiar optimizaciones
	docker-compose exec app php artisan optimize:clear

key-generate: ## Generar APP_KEY
	docker-compose exec app php artisan key:generate

storage-link: ## Crear symlink storage
	docker-compose exec app php artisan storage:link

permissions: ## Arreglar permisos
	docker-compose exec -u root app chown -R laravel:laravel /var/www/html
	docker-compose exec app chmod -R 775 /var/www/html/storage
	docker-compose exec app chmod -R 775 /var/www/html/bootstrap/cache

queue-work: ## Ejecutar queue worker
	docker-compose exec app php artisan queue:work

queue-restart: ## Reiniciar queue workers
	docker-compose exec app php artisan queue:restart

redis-cli: ## Entrar a Redis CLI
	docker exec -it $(REDIS_CONTAINER) redis-cli

redis-flush: ## Limpiar Redis
	docker exec -it $(REDIS_CONTAINER) redis-cli FLUSHALL

mysql-cli: ## Entrar a MySQL CLI
	docker exec -it $(MYSQL_CONTAINER) mysql -u gourest -pgourest_secret gourest

mysql-root: ## Entrar a MySQL como root
	docker exec -it $(MYSQL_CONTAINER) mysql -u root -proot_gourest_2024

mysql-dump: ## Backup de base de datos
	docker exec $(MYSQL_CONTAINER) mysqldump -u gourest -pgourest_secret gourest > backup_$(shell date +%Y%m%d_%H%M%S).sql

setup: build up composer key-generate migrate storage-link permissions ## Setup inicial completo

fresh: down-volumes up migrate-fresh permissions ## Reset completo con volúmenes

status: ## Ver estado de contenedores
	docker-compose ps

stats: ## Ver estadísticas de recursos
	docker stats $(APP_CONTAINER) $(NGINX_CONTAINER) $(MYSQL_CONTAINER) $(REDIS_CONTAINER)

prune: ## Limpiar Docker (cuidado!)
	docker system prune -a --volumes