#FROM centos/ruby-22-centos7
#USER default
#EXPOSE 8080
#ENV RACK_ENV production
#ENV RAILS_ENV production
#COPY . /opt/app-root/src/
#RUN scl enable rh-ruby22 "bundle install"
#CMD ["scl", "enable", "rh-ruby22", "./run.sh"]

#USER root
#RUN chmod og+rw /opt/app-root/src/db

#RUN yum install -y httpd
#USER default
FROM openshift/base-centos7

# This image provides a Ruby 2.0 environment you can use to run your Ruby
# applications.

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

EXPOSE 8080

ENV RUBY_VERSION 2.0

LABEL io.k8s.description="Platform for building and running Ruby 2.0 applications" \
      io.k8s.display-name="Ruby 2.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,ruby20"

RUN INSTALL_PKGS="ruby200 ruby200-ruby-devel ruby200-rubygem-rake v8314 ror40-rubygem-bundler nodejs010" && \
    yum install -y centos-release-scl && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
#COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
#COPY ./contrib/ /opt/app-root

RUN chown -R 1001:0 /opt/app-root

ONBUILD COPY Gemfile /usr/src/app/
ONBUILD COPY Gemfile.lock /usr/src/app/
ONBUILD RUN bundle install

ONBUILD COPY . /usr/src/app
RUN rm /bin/sh

USER 1001

# Set the default CMD to print the usage of the language image
