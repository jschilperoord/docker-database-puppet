FROM oraclelinux:6.6

RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 \
 && rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN yum -y install hostname.x86_64 rubygems ruby-devel gcc git unzip
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

RUN rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs && \
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# configure & install puppet
RUN yum install -y puppet tar
RUN gem install -y highline -v 1.6.21
RUN gem install -y librarian-puppet -v 1.0.3

RUN yum clean all

ADD puppet/Puppetfile /etc/puppet/
ADD puppet/manifests/site.pp /etc/puppet/

WORKDIR /etc/puppet/
RUN librarian-puppet install

ADD custom.dbt.erb /etc/puppet/modules/oradb/templates/custom.dbt.erb

# upload software
RUN mkdir /var/tmp/install
RUN chmod 777 /var/tmp/install

RUN mkdir /software

COPY p13390677_112040_Linux-x86-64_1of7.zip /software/
COPY p13390677_112040_Linux-x86-64_2of7.zip /software/

RUN chmod -R 777 /software

RUN puppet apply /etc/puppet/site.pp --verbose --detailed-exitcodes || [ $? -eq 2 ]

RUN pip install --upgrade 'pip >= 1.4, < 1.5' \
    && pip install --upgrade supervisor supervisor-stdout \
    && mkdir -p /var/log/supervisor/ \
    && yum clean all

EXPOSE 1521

ADD startup.sh /
RUN chmod 0755 /startup.sh

WORKDIR /

# cleanup
RUN rm -rf /software/*
RUN rm -rf /var/tmp/install/*
RUN rm -rf /var/tmp/*
RUN rm -rf /var/cache/yum/*
RUN rm -rf /tmp/*

COPY supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
