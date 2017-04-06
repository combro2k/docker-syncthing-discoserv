#!/bin/bash

trap '{ echo -e "error ${?}\nthe command executing at the time of the error was\n${BASH_COMMAND}\non line ${BASH_LINENO[0]}" && tail -n 10 ${INSTALL_LOG} && exit $? }' ERR

export DEBIAN_FRONTEND="noninteractive"
export SYNCTHING_VERSION="0.14.26"

pre_install() {
	apt-get update -q || return 1
	apt-get install -yq tar curl ca-certificates sudo || return 1

	useradd stdiscosrv -b /var/stdiscosrv || return 1
    	mkdir -p /opt/stdiscosrv /var/stdiscosrv /usr/local/go /usr/local/go/src/github.com/syncthing/syncthing || return 1

    	return 0
}

install() {
	curl --location --silent https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz | tar zx -C /usr/local/go --strip-components=1 || return 1
	curl --location --silent https://github.com/syncthing/syncthing/archive/v${SYNCTHING_VERSION}.tar.gz | tar zx -C /usr/local/go/src/github.com/syncthing/syncthing --strip-components=1 || return 1
	ln -s /usr/local/go/bin/go /usr/local/bin/go || return 1

	cd /usr/local/go/src/github.com/syncthing/syncthing || return 1
	go run build.go -version v${SYNCTHING_VERSION} || return 1

	mv /usr/local/go/src/github.com/syncthing/syncthing/bin/stdiscosrv /opt/stdiscosrv/stdiscosrv || return 1

	return 0
}

post_install() {
	apt-get autoremove 2>&1 || return 1
	apt-get autoclean 2>&1 || return 1
	rm -fr /var/lib/apt /usr/local/go 2>&1 || return 1

	chmod +x /usr/local/bin/* || return 1

	return 0
}

build() {
	if [ ! -f "${INSTALL_LOG}" ]
	then
		touch "${INSTALL_LOG}" || exit 1
	fi

	tasks=(
        'pre_install'
	'install'
	)

	for task in ${tasks[@]}
	do
		echo "Running build task ${task}..." || exit 1
		${task} | tee -a "${INSTALL_LOG}" || exit 1
	done
}

if [ $# -eq 0 ]
then
	echo "No parameters given! (${@})"
	echo "Available functions:"
	echo

	compgen -A function

	exit 1
else
	for task in ${@}
	do
		echo "Running ${task}..." 2>&1  || exit 1
		${task} || exit 1
	done
fi
