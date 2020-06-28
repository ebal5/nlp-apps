FROM alpine:3.12.0

ENV PATH=/usr/local/bin:$PATH
ENV LANG=C.UTF-8
ENV SHELL=/bin/ash

RUN set -ex ;\
  apk update ;\
  apk add --no-cache ca-certificates=20191127-r4 && \
  apk add --no-cache --virtual .fetch-deps && \
  apk add --no-cache --virtual .build-deps \
  boost=1.72.0-r6 \
  boost-dev=1.72.0-r6 \
  bzip2-dev=1.0.8-r1 \
  cmake=3.17.2-r0 \
  coreutils=8.32-r0 \
  curl=7.69.1-r0 \
  dpkg-dev=1.20.0-r0 dpkg=1.20.0-r0 \
  expat-dev=2.2.9-r1 \
  file=5.38-r0 \
  findutils=4.7.0-r0 \
  g++=9.3.0-r2 \
  gcc=9.3.0-r2 \
  gdbm-dev=1.13-r1 \
  gnupg=2.2.20-r0 \
  libc-dev=0.7.2-r3 \
  libffi-dev=3.3-r2 \
  libnsl-dev=1.2.0-r1 \
  libstdc++=9.3.0-r2 \
  libtirpc-dev=1.2.6-r0 \
  linux-headers=5.4.5-r1 \
  make=4.3-r0 \
  ncurses-dev=6.2_p20200523-r0 \
  openssl-dev=1.1.1g-r0 \
  patch=2.7.6-r6 \
  # pax-utils=1.2.6-r6 \
  readline-dev=8.0.4-r0 \
  ruby=2.7.1-r3 ruby-dev=2.7.1-r3 \
  sqlite-dev=3.32.1-r0 \
  tar=1.32-r1 \
  tcl-dev=8.6.10-r0 \
  tk=8.6.10-r1 \
  tk-dev=8.6.10-r1 \
  util-linux-dev=2.35.2-r0 \
  xz=5.2.5-r0 \
  xz-dev=5.2.5-r0 \
  zlib-dev=1.2.11-r3 \
  && apk del .fetch-deps ; \
  mkdir /usr/local/src


WORKDIR /usr/local/src
COPY const.h.patch .
# hadolint ignore=SC2039,DL4006
RUN set -ex -o pipefail ;\
  # Download mecab and extract it to /usr/local/src
  curl -sLJ "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" | tar zxf - -C /usr/local/src ; \
  # Download mecab jumandic and extract it to /usr/local/src
  curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7X2pESGlLREpxdXM" > /dev/null ; \
  curl -sLJb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=$(awk '/_warning_/ {print $NF}' /tmp/cookie)&id=0B4y35FiV1wh7X2pESGlLREpxdXM" | tar zxf - -C /usr/local/src ; \
  rm /tmp/cookie ; \
  cd /usr/local/src/mecab-0.996 \
  && ./configure --prefix=/usr/local > /dev/null && make > /dev/null && make check && make install ; \
  mecab --help && rm -rf /usr/local/src/mecab-0.996 ; \
  cd /usr/local/src/mecab-jumandic-7.0-20130310 \
  && ./configure --prefix=/usr/local > /dev/null && make > /dev/null && make install ; \
  rm -rf /usr/local/src/mecab-jumandic-7.0-20130310 ; \
  # Download jumanpp 1.02 and make it
  cd /root ; \
  curl -C - -sLJ -o jumanpp-1.02.tar.xz "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://lotus.kuee.kyoto-u.ac.jp/nl-resource/jumanpp/jumanpp-1.02.tar.xz&name=jumanpp-1.02.tar.xz" ; \
  curl -C - -sLJ -o "jumanpp-1.02.tar.xz" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://lotus.kuee.kyoto-u.ac.jp/nl-resource/jumanpp/jumanpp-1.02.tar.xz&name=jumanpp-1.02.tar.xz" ; \
  tar xJf "jumanpp-1.02.tar.xz" -C /usr/local/src ; \
  cd /usr/local/src/jumanpp-1.02 \
  && ./configure --prefix=/usr/local > /dev/null && make > /dev/null && make install ; \
  # Download juman 7.01 and make it
  cd /root ; \
  curl -C - -sLJ -o "juman-7.01.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2" ; \
  curl -C - -sLJ -o "juman-7.01.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2" ; \
  tar xjf "juman-7.01.tar.bz2" -C /usr/local/src ; \
  rm -f "juman-7.01.tar.bz2" ; \
  cd /usr/local/src/juman-7.01 ; cp /usr/local/src/jumanpp-1.02/dict-build/grammar/* ./dic/ ; \
  sed -ie 's/6000/6100/' makemat/makemat.c \
  && ./configure --prefix=/usr/local && make && make install ; \
  rm -rf /usr/local/src/juman-7.01 ; \
  rm -rf /usr/local/src/jumanpp-1.02 ; \
  # Download knp 4.19 and make it
  cd /root ;\
  curl -C - -sLJ -o "knp-4.19.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.19.tar.bz2&name=knp-4.19.tar.bz2" ; \
  curl -C - -sLJ -o "knp-4.19.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.19.tar.bz2&name=knp-4.19.tar.bz2" ; \
  tar xjf "knp-4.19.tar.bz2" -C /usr/local/src ; \
  rm -f knp-4.19.tar.bz2 ; \
  cd /usr/local/src/knp-4.19 \
  && patch system/const.h /usr/local/src/const.h.patch \
  && rm /usr/local/src/const.h.patch \
  && ./configure --prefix=/usr/local --with-juman-prefix=/usr/local && make && make install ; \
  rm -rf /usr/local/src/knp-4.19
