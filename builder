#!/usr/bin/env bash

shopt -s extglob

start_dir=`pwd`
nginx_install_dir="$HOME/nginx"
nginx_stage_dir="$start_dir/tmp/stage"
virtualenv_dir="$HOME/env"
pip_install="$virtualenv_dir/bin/pip install"


msg() {
    echo -e "\033[1;32m-->\033[0m $0:" $*
}

die() {
    msg $*
    exit 1
}

move_to_approot() {
    msg "moving to $SERVICE_APPROOT"
    [ -n "$SERVICE_APPROOT" ] && cd $SERVICE_APPROOT
}

create_virtualenv() {
    if [ ! -d $virtualenv_dir ] ; then
        msg "building virtualenv: $virtualenv_dir"
        virtualenv $virtualenv_dir
    else
        msg "virtualenv already exists: $virtualenv_dir"
    fi
    ls -al $virtualenv_dir
}

install_requirements(){
    if [-f $HOME/current/requirements.txt ]; then
        msg "found requirements.txt file installing requirements"
        $pip_install --download-cache=~/.pip-cache -r $HOME/current/requirements.txt
    else
        msg "no requirements to install"
    fi
}

install_uwsgi() {
    msg "install uwsgi from pip:"
     $pip_install uwsgi
}

install_nginx() {
    local nginx_url="http://nginx.org/download/nginx-1.0.12.tar.gz"

    msg "Nginx install directory: $nginx_install_dir"

    # install nginx
    if [ ! -d $nginx_install_dir ] ; then
        # just temp until I figure out what is wrong with build.
        #rm -rf $nginx_install_dir
        #rm -rf $nginx_stage_dir
    #fi
        mkdir -p $nginx_install_dir
        mkdir -p $nginx_stage_dir

        wget -O - $nginx_url | tar -C $nginx_stage_dir --strip-components=1 -zxf -
        [ $? -eq 0 ] || die "can't fetch nginx"

        msg "Current directory listing"
        ls 
        msg "move into $nginx_stage_dir "
        cd $nginx_stage_dir 
        msg "$nginx_stage_dir listing"
        ls $nginx_stage_dir
        msg "now try to compile"
        export CFLAGS="-O3 -pipe"
           ./configure   \
            --prefix=$nginx_install_dir \
            --with-http_addition_module \
            --with-http_dav_module \
            --with-http_geoip_module \
            --with-http_gzip_static_module \
            --with-http_realip_module \
            --with-http_stub_status_module \
            --with-http_ssl_module \
            --with-http_sub_module \
            --with-http_xslt_module && make && make install
        [ $? -eq 0 ] || die "Nginx install failed"
        
        ls -al $nginx_install_dir
        rm $nginx_install_dir/conf/*.default
    else
        msg "Nginx already installed"
    fi
    
    #move_to_approot
    ls -al
    msg "ls of HOME: $HOME"
    ls -al $HOME
    msg "ls of app root : $SERVICE_APPROOT"
    ls -al $SERVICE_APPROOT
    msg "update nginx configuration file"
    # update nginx configuration file
    # XXX: PORT_WWW is missing in the environment at build time
    # moved to postinstall script
    #sed > $nginx_install_dir/conf/nginx.conf < $start_dir/nginx.conf.in    \
    #    -e "s/@PORT_WWW@/${PORT_WWW:-42800}/g"
    
    msg "cleaning up $nginx_stage_dir"
    rm -rf $nginx_stage_dir
}

install_supervisor_config(){
    msg "supervisor.conf from $HOME before"
    cat $HOME/supervisor.conf
    msg "copy supervisor.conf from $start_dir to $HOME"
    cp -f $start_dir/supervisor.conf $HOME
    msg "supervisor.conf from $HOME after"
    cat $HOME/supervisor.conf
}

install_application() {
    cat >> $start_dir/profile << EOF
export PATH="$nginx_install_dir/sbin:$PATH"
EOF
    mv $start_dir/profile ~/

    # Use ~/code and ~/current like the regular Ruby service for better compatibility
    msg "installing application to ~/current/ from $start_dir"
    #pwd
    #cd $start_dir
    #ls -al
    #pwd
    msg "start rsyncing"
    rsync -avH --delete --exclude "data" * ~/current/
}

msg "Starting at $start_dir"
msg "Move to app root"
move_to_approot
msg "create virtualenv"
create_virtualenv
msg "install uwsgi"
install_uwsgi
msg "install nginx"
install_nginx # could be replaced by something else
#msg "install supervisor config"
#install_supervisor_config
msg "install application"
install_application
msg "install requirements" #maybe move after create virtualenv
install_requirements