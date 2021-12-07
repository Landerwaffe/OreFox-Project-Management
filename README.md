# OreFox-Project-Management
Summer Project for OreFox

## How to run the app
- Clone this project
- Create and activate virtual environment
- cd to the Orefox-Project-Management-main directory and install requirements through pip ```pip install -r requirements.txt```
- cd to src directory
- Make migrations with `python manage.py makemigrations`, then migrate the database with `python manage.py migrate`
- Create a superuser with `python manage.py createsuperuser`, then follow the instructions
- Start the application with `python manage.py runserver`
- You are now ready to use the application... Go to the site http://127.0.0.1:8000/
