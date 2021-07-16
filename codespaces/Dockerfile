FROM jrei/systemd-debian

RUN apt-get update && \
	apt-get install -y \
	ca-certificates \
	gpg \
        local-apt-repository && \
	gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
        gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | apt-key add - && \
	echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/10/prod buster main' > /etc/apt/sources.list.d/microsoft.list && \
	rm -rf /var/lib/apt/lists/* && \
	rm -f /usr/sbin/policy-rc.d
