# Build stage - install dependencies
FROM ruby:2.7.2-slim AS builder

# Fix for Debian Buster EOL - use archive repositories
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list

RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    git \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/osb

RUN gem install bundler -v 2.4.22 --no-document

COPY Gemfile Gemfile.lock ./
COPY vendor/engines ./vendor/engines/

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test"

RUN bundle install --jobs 4 --retry 3 \
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

# Runtime stage - minimal image
FROM ruby:2.7.2-slim

# Fix for Debian Buster EOL - use archive repositories
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list

RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y --no-install-recommends \
    libpq5 \
    nodejs \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN gem install bundler -v 2.4.22 --no-document

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    PATH="/usr/local/bundle/bin:$PATH"

WORKDIR /usr/src/osb

COPY --from=builder /usr/local/bundle /usr/local/bundle

COPY . /usr/src/osb

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

COPY ./docker/app/wait-for-it.sh ./docker/app/wait-for-it.sh
RUN chmod +x ./docker/app/wait-for-it.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000", "-e", "production"]
