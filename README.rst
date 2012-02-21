Python-on-dotcloud custom service
---------------------------------

This is a beta version of the custom python service on dotCloud. Feel free to use, but keep your eyes open for issues. If you find any issues please report them.


How to use
----------
Clone this repo and use it as a base for your custom service. You will need to replace the wsgi.py file with your own, and make sure you add all of your application files. Don't change the builder or postinstall scripts unless you know what you are doing, or else you could break it.


Why use this service
--------------------
If the generic python service doesn't do what you need, you can use this service to customize the python service to do what you need. The most requested feature is the ability to change the uwsgi configuration. If you want to do that you just need to change the uwsgi.sh file.


NewRelic
--------
If you would like to use NewRelic to monitor your python application all you need to do is add an environment variable with your new_relic license key, and this build script will do the rest.

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
                # add your license key. Comment it out, or remove all together if you want it disabled.
            newrelic_license_key: 1234ABCooFAKEoKEYoofasdfsaf1234
