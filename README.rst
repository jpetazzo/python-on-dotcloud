Python-on-dotcloud custom service
---------------------------------

This is a beta version of the custom python service on dotCloud. Feel free to use, but keep your eyes open for issues. If you find any issues please report them.


How to use
----------
Clone this repo and use it as a base for your custom service. You will need to replace the wsgi.py file with your own, and make sure you add all of your application files. Don't change the builder or postinstall scripts unless you know what you are doing, or else you could break it.


Why use this service
--------------------
If the generic python service doesn't do what you need, you can use this service to customize the python service to do what you need. The most requested feature is the ability to change the uwsgi configuration. If you want to do that you just need to change the uwsgi.sh file.
