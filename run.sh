#i/bin/sh

install(){
    while IFS= read -r line; do
        if [ ! "$line" = "frappe" ] && [ ! "$line" = "" ]; then
            echo "Installing app: $line"
            ./env/bin/pip install -e  ./other_apps/$line
     fi
    done < ./sites/apps.txt

}
dev(){
    cat <<"EOF"
     _                                  _
    | |                                | |
  __| | _____   __  _ __ ___   ___   __| | ___
 / _` |/ _ \ \ / / | '_ ` _ \ / _ \ / _` |/ _ \
| (_| |  __/\ V /  | | | | | | (_) | (_| |  __/
 \__,_|\___| \_/   |_| |_| |_|\___/ \__,_|\___|

EOF
    install
    bench start
}


prod(){
    cat <<"EOF"
                     _                       _
                    | |                     | |
 _ __  _ __ ___   __| |  _ __ ___   ___   __| | ___
| '_ \| '__/ _ \ / _` | | '_ ` _ \ / _ \ / _` |/ _ \
| |_) | | | (_) | (_| | | | | | | | (_) | (_| |  __/
| .__/|_|  \___/ \__,_| |_| |_| |_|\___/ \__,_|\___|
| |
|_|

EOF
    build
    cd /home/frappe/frappe-bench/sites && /home/frappe/frappe-bench/env/bin/gunicorn -b 0.0.0.0:8000 --workers 8 --threads 4 -t 120 frappe.app:application --preload

}


build(){
    bench build;
    install;
    cd /home/frappe/frappe-bench/sites/assets;
    for link in $(find . -type l);
    do
        loc="$(dirname "$link")";
        dir="$(readlink "$link")";
        rm "$link";
        cp -r -L "$dir" "$link";
        rm -rf public
    done
}


main(){
    if [ "$mode" = "prod" ]; then
        prod
    else
       dev
    fi
}


main "$@"
