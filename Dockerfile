FROM alpine:latest

ENV PATH=/usr/local/bin:$PATH
ENV LANG=C.UTF-8

RUN set -ex ;\
  apk add --no-cache ca-certificates && \
  apk add --no-cache --virtual .fetch-deps && \
  apk add --no-cache --virtual .build-deps \
  gnupg tar xz \
  bzip2-dev \
  coreutils \
  dpkg-dev dpkg \
  expat-dev \
  findutils \
  gcc \
  g++ \
  gdbm-dev \
  libc-dev \
  libstdc++ \
  libffi-dev \
  libnsl-dev \
  libtirpc-dev \
  linux-headers \
  boost \
  boost-dev \
  make \
  cmake \
  ncurses-dev \
  openssl-dev \
  pax-utils \
  readline-dev \
  sqlite-dev \
  tcl-dev \
  tk \
  tk-dev \
  util-linux-dev \
  xz-dev \
  zlib-dev \
  curl \
  file \
  # add build deps before removing fetch deps in case there's overlap
  && apk del .fetch-deps ; \
  mkdir /usr/local/src

COPY const.h.patch /

RUN set -ex ;\
  apk add --no-cache ruby ruby-dev ; \
  curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" | tar zxf - -C /usr/local/src ; \
  curl -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7X2pESGlLREpxdXM" | tar zxf - -C /usr/local/src ; \
  cd /usr/local/src/mecab-0.996 \
  && ./configure --prefix=/usr/local && make && make check && make install ; \
  mecab --help \
  && cd /usr/local/src/mecab-jumandic-7.0-20130310 \
  && ./configure --prefix=/usr/local && make && make install ; \
  curl -L "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://lotus.kuee.kyoto-u.ac.jp/nl-resource/jumanpp/jumanpp-1.02.tar.xz&name=jumanpp-1.02.tar.xz" | tar xJf - -C /usr/local/src ; \
  cd /usr/local/src/jumanpp-1.02 \
  && ./configure --prefix=/usr/local && make && make install ; \
  jumanpp --help \
  && curl -L "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2" | tar xjf - -C /usr/local/src ; \
  cd /usr/local/src/juman-7.01 ; cp /usr/local/src/jumanpp-1.02/dict-build/grammar/* ./dic/ ; \
  sed -ie 's/6000/6100/' makemat/makemat.c \
  && ./configure --prefix=/usr/local && make && make install ; \
  curl -L "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.19.tar.bz2&name=knp-4.19.tar.bz2" | tar xjf - -C /usr/local/src ; \
  cd /usr/local/src/knp-4.19 \
  && patch system/const.h /const.h.patch \
  && ./configure --prefix=/usr/local --with-juman-prefix=/usr/local && make && make install
