# AA-In-A-Box
Alliance Auth in a box is the development environment for Alliance Auth in a docker container.

If you're as lazy as me and don't want to create a VM/WSL environment, use this docker image.

## Configure

- Go to `https://developers.eveonline.com/` and create a new application.
- Open the `local.py`, add the client id and client secret.

## Instructions

- Run `docker compose build`
- Start the container `docker compose up -d`
- Exec into the container `docker compose exec aa-dev bash`

- Activate the Python venv `sourve venv/bin/activate`
- Start the mysql and redis server `./start-services.sh`
- Change directory into myauth `cd myauth/`
- Run migrations `python manage.py migrate`
- Run the server `python manage.py runserver 0.0.0.0:8000`

## Information

- When you to change your local.py, do it inside the containers with `vim /opt/aa-dev/myauth/myauth/settings/local.py`. If you change it on your host, the container will rebuild and you have to recreate your AA instance again. 
- Download or create plugins on your host in folder `plugins/` (will be created by Docker). Then activate the virtual environment in the container with `sourve venv/bin/activate`, go into the `plugins/` folder and run `pip install -e <folder>`