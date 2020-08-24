FROM jrei/systemd-debian

RUN apt-get update && \
	apt-get install -y \
	ca-certificates \
	gpg \
	&& gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C && \
	gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
	gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | apt-key add - && \
gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | apt-key add - && \
	echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/10/prod buster main' > /etc/apt/sources.list.d/microsoft.list && \
	echo 'deb https://deb.ln-ask.me/beta buster common local desktop' > /etc/apt/sources.list.d/cryptoanarchy.list && \
	rm -rf /var/lib/apt/lists/* && \
	rm -f /usr/sbin/policy-rc.d
