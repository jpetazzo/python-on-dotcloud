Python-on-dotcloud custom service
---------------------------------

This is a beta version of the custom python service on dotCloud. Feel free to use, but keep your eyes open for issues. If you find any issues please report them.


How to use
----------
Clone this repo and use it as a base for your custom service. You will need to replace the wsgi.py file with your own, and make sure you add all of your application files. Don't change the builder or postinstall scripts unless you know what you are doing, or else you could break it.


Why use this service
--------------------
If the generic python service doesn't do what you need, you can use this service to customize the python service to do what you need. The most requested feature is the ability to change the uwsgi configuration. If you want to do that you just need to change the uwsgi.sh file.

Python Version
--------------
This custom service supports 4 different branches of python (2.6, 2.7, 3.1, 3.2), it will default to python 2.6 unless you specify otherwise. The current versions of each python branch are listed in the table below. Pick the branch that works best for you.

+--------+---------+
| branch | version |
+========+=========+
| 2.6*   | 2.6.5   |
+--------+---------+
| 2.7    | 2.7.2   |
+--------+---------+
| 3.1    | 3.1.2   |
+--------+---------+
| 3.2    | 3.2.2   |
+--------+---------+

\* python 2.6 is the default

Here is an example of the dotcloud.yml file for setting the python version to 3.2::

    python:
        type: custom
        buildscript: builder
        systempackages:
            # needed for the Nginx rewrite module
            - libpcre3-dev
        ports:
            www: http
        processes:
            nginx: nginx
            uwsgi: ~/uwsgi.sh
        config:
            python_version: 3.2

NewRelic
--------
If you would like to use NewRelic to monitor your python application all you need to do is add an environment variable with your new_relic license key and application name, and this build script will do the rest.

Here is an example of a dotcloud.yml with NewRelic turned on::

    python:
        type: custom
        buildscript: builder
        systempackages:
            # needed for the Nginx rewrite module
            - libpcre3-dev
        ports:
            www: http
        processes:
            nginx: nginx
            uwsgi: ~/uwsgi.sh
        config:
                # This is only needed if you want to enable new relic support
                # add your license key and app name. Comment it out, or remove all together if you want it disabled.
            newrelic_license_key: 1234ABCooFAKEoKEYoofasdfsaf1234
            newrelic_app_name: Custom Python application on dotCloud


You will also need to make sure you have your wsgi.py is setup correctly. If you don't have it setup correctly then newrelic won't be able to gather data correctly. See these pages at NewRelic for more information. 

- http://newrelic.com/docs/python/python-agent-and-uwsgi
- http://newrelic.com/docs/python/integration-with-python-application

Here is an example of my sample wsgi.py file with NewRelic installed::

    #!/usr/bin/env python
    
    # This is just an example, replace this with your own wsgi.py file
    
    # because this is such a simple wsgi file I need to manually add the newrelic decorator to the WSGI application entry point. If
    # you are using a real web framework this is most likely not needed.

    import newrelic.agent

    @newrelic.agent.wsgi_application()
    def application(environ, start_response):
        start_response('200 OK', [('Content-Type', 'text/plain')])
        return ['Hello, world!\n']