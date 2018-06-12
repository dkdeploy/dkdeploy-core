FROM rastasheep/ubuntu-sshd:16.04
# Install locales
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Create test user and group
Run adduser 'test-user' --no-create-home --gecos "" --disabled-login
RUN groupadd 'test-group'
RUN usermod -aG 'test-group' 'test-user'

RUN apt-get update && apt-get install -y \
  apache2-utils \
  mysql-client \
  # Need for gem "dkdeploy-test_environment". Use commands like "sudo rm ..."
  sudo \
  # Need for gem "dkdeploy-test_environment".
  less \
  rsync

RUN mkdir -p /var/www

