FROM alpine:latest

ENV PATH=/usr/local/bin:$PATH
ENV LANG=C.UTF-8

RUN set -ex ;\
  apk update ;\
  apk add --no-cache ca-certificates && \
  apk add --no-cache --virtual .fetch-deps && \
  apk add --no-cache --virtual .build-deps \
  boost \
  boost-dev \
  bzip2-dev \
  cmake \
  coreutils \
  curl \
  dpkg-dev dpkg \
  expat-dev \
  file \
  findutils \
  g++ \
  gcc \
  gdbm-dev \
  gnupg \
  libc-dev \
  libffi-dev \
  libnsl-dev \
  libstdc++ \
  libtirpc-dev \
  linux-headers \
  make \
  ncurses-dev \
  openssl-dev \
  patch \
  pax-utils \
  readline-dev \
  sqlite-dev \
  tar \
  tcl-dev \
  tk \
  tk-dev \
  util-linux-dev \
  xz \
  xz-dev \
  zlib-dev \
  # add build deps before removing fetch deps in case there's overlap
  && apk del .fetch-deps ; \
  mkdir /usr/local/src

COPY const.h.patch /

RUN set -ex ;\
  apk add --no-cache ruby ruby-dev ; \
  # Download mecab and extract it to /usr/local/src
  curl -sLJ "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" | tar zxf - -C /usr/local/src ; \
  # Download mecab jumandic and extract it to /usr/local/src
  curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7X2pESGlLREpxdXM" > /dev/null ; \
  CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)" curl -sLJb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=$(awk '/_warning_/ {print $NF}' /tmp/cookie)&id=0B4y35FiV1wh7X2pESGlLREpxdXM" | tar zxf - -C /usr/local/src ; \
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
  jumanpp --help && rm -rf /usr/local/src/jumanpp-1.02 ; \
  # Download juman 7.01 and make it
  cd /root ; \
  curl -C - -sLJ -o "juman-7.01.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2" ; \
  curl -C - -sLJ -o "juman-7.01.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2" ; \
  tar xjf "juman-7.01.tar.bz2" -C /usr/local/src ; \
  rm -f "juman-7.01.tar.bz2" ; \
  cd /usr/local/src/juman-7.01 ; cp /usr/local/src/jumanpp-1.02/dict-build/grammar/* ./dic/ ; \
  sed -ie 's/6000/6100/' makemat/makemat.c \
  && ./configure --prefix=/usr/local && make && make install ; \
  juman --help && rm -rf /usr/local/src/juman-7.01 ; \
  # Download knp 4.19 and make it
  cd /root ;\
  curl -C - -sLJ -o "knp-4.19.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.19.tar.bz2&name=knp-4.19.tar.bz2" ; \
  curl -C - -sLJ -o "knp-4.19.tar.bz2" "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.19.tar.bz2&name=knp-4.19.tar.bz2" ; \
  tar xjf "knp-4.19.tar.bz2" -C /usr/local/src ; \
  rm -f knp-4.19.tar.bz2 ; \
  cd /usr/local/src/knp-4.19 \
  && patch system/const.h /const.h.patch \
  && rm /const.h.patch \
  && ./configure --prefix=/usr/local --with-juman-prefix=/usr/local && make && make install ; \
  knp --help \
  && rm -rf /usr/local/src/knp-4.19
