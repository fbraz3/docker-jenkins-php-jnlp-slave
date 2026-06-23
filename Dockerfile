ARG PHP_VERSION=8.2
FROM fbraz3/php-cli:$PHP_VERSION

# Bring in the Jenkins agent binaries
COPY --from=jenkins/inbound-agent /usr/share/jenkins/agent.jar /usr/share/jenkins/agent.jar
COPY --from=jenkins/inbound-agent /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-agent

USER root
ARG PHP_VERSION

# Install Java and extra dependencies needed for Jenkins/Builds
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -yq --no-install-recommends \
        openjdk-17-jre-headless \
        mariadb-client \
        php$PHP_VERSION-xdebug && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN mkdir -p /opt/composer && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/opt/composer --filename=composer.phar && \
    chmod +x /opt/composer/composer.phar && \
    ln -sf /opt/composer/composer.phar /usr/local/bin/composer

# Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv $HOME/.symfony5/bin/symfony /usr/local/bin/symfony

# Re-configure php user to jenkins user
RUN usermod -l jenkins php && \
    groupmod -n jenkins php && \
    usermod -d /home/jenkins -m jenkins && \
    chown -R jenkins:jenkins /home/jenkins

# Verify PHP version is correct
RUN [ "$PHP_VERSION" = "$(php -r 'echo PHP_MAJOR_VERSION,chr(46),PHP_MINOR_VERSION;')" ]

USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
