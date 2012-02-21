#!/usr/bin/env bash

shopt -s extglob

# variables needed later.
start_dir=`pwd`
nginx_install_dir="$HOME/nginx"
stage_dir="$start_dir/tmp"
nginx_stage_dir="$stage_dir/stage"
virtualenv_dir="$HOME/env"
pip_install="$virtualenv_dir/bin/pip install"
requirments_file="$HOME/current/requirements.txt"

# functions
msg() {
    echo -e "\033[1;32m-->\033[0m $0:" $*
}

die() {
    msg $*
    exit 1
}

move_to_approot() {
    [ -n "$SERVICE_APPROOT" ] && cd $SERVICE_APPROOT
}

create_virtualenv() {
    if [ ! -d $virtualenv_dir ] ; then
        msg "building virtualenv @ $virtualenv_dir"
        virtualenv $virtualenv_dir
    else
        msg "virtualenv already exists @ $virtualenv_dir , skipping install."
    fi
}

install_requirements(){
    if [ -e "$requirments_file" ]; then
        msg "found requirements.txt file installing requirements from $requirments_file"
        $pip_install --download-cache=~/.pip-cache -r $requirments_file
    else
        msg "looked for requirements file at ($requirments_file) and didn't find one. skipping requirements install"
    fi
}

install_uwsgi() {
    msg "install uwsgi from pip:"
    $pip_install uwsgi
}

install_nginx() {
    local nginx_url="http://nginx.org/download/nginx-1.0.12.tar.gz" #TODO parametrize? 

    msg "installing Nginx into: $nginx_install_dir"

    # install nginx
    if [ ! -d $nginx_install_dir ] ; then
        msg "making directory: $nginx_install_dir "
        mkdir -p $nginx_install_dir
        
        msg "making directory: $nginx_stage_dir "
        mkdir -p $nginx_stage_dir

        msg "downloading nginx from ($nginx_url) and untaring into ($nginx_stage_dir) "
        wget -O - $nginx_url | tar -C $nginx_stage_dir --strip-components=1 -zxf -
        [ $? -eq 0 ] || die "can't fetch nginx"

        msg "Successfully download and untarred nginx"
        
        msg "move into $nginx_stage_dir "
        cd $nginx_stage_dir 
        
        msg "trying to compile nginx, and then install it"
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
        
        msg "Successfully compiled and installed nginx"
        
        msg "remove some of the default config files from the nginx config directory that aren't needed"
        rm $nginx_install_dir/conf/*.default
        
        msg "cleaning up ($stage_dir) since it is no longer needed."
        rm -rf $stage_dir
        
        msg "finished installing nginx."
    else
        msg "Nginx already installed, skipping this step."
    fi

}

install_application() {
    cat >> $start_dir/profile << EOF
export PATH="$nginx_install_dir/sbin:$PATH"
EOF
    msg "change directories to $start_dir"
    cd $start_dir
    
    msg "moving $start_dir/profile to ~/"
    mv $start_dir/profile ~/
    
    msg "moving $start_dir/uwsgi.sh to ~/"
    mv $start_dir/uwsgi.sh ~/

    # Use ~/code and ~/current like the regular python service for better compatibility
    msg "installing application to ~/current/ from $start_dir"

    rsync -avH --delete --exclude "data" * ~/current/
}

# lets get started.

msg "Step 0: getting ready for build::"
move_to_approot

msg "Step 1: create virtualenv::"
create_virtualenv

msg "Step 2: install uwsgi::"
install_uwsgi

msg "Step 3: install nginx::"
install_nginx

msg "Step 4: install application::"
install_application

msg "Step 5: install application specific requirements::"
install_requirements

msg "All done..."