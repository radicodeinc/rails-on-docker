FROM centos:7
MAINTAINER kotera@radicode.co.jp

RUN sed -i -e '/override_install_langs/s/$/,ja_JP.utf8/g' /etc/yum.conf
RUN yum -y reinstall glibc-common
RUN localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8; echo "";

ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

CMD date

RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.5.1"
ENV rails_ver="5.1.4"

# 必要なパッケージをインストール
RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install vim which git make autoconf curl wget gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel sqlite-devel bzip2
RUN yum clean all

# rubyとbundleをダウンロード
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# コマンドでrbenvが使えるように設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

ENV RBENV_ROOT="/usr/local/rbenv" \
    GEM_HOME="/usr/local/bundle" 
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH="$BUNDLE_BIN:$RBENV_ROOT:/bin:/usr/local/rbenv/versions/${ruby_ver}/bin:$PATH"
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
    && chmod 775 "$GEM_HOME" "$BUNDLE_BIN" 

# rubyとrailsをインストール
RUN source /etc/profile.d/rbenv.sh; rbenv install ${ruby_ver}; rbenv global ${ruby_ver}; ruby -v; gem -v;
RUN source /etc/profile.d/rbenv.sh; gem update --system; gem install --version ${rails_ver} --no-ri --no-rdoc rails; gem install bundle; bundle -v;

