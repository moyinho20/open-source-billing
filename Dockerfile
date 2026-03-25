FROM ruby:2.7.2

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    imagemagick \
    wkhtmltopdf \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
COPY vendor/engines ./vendor/engines/
RUN bundle install --without development test --jobs 4 --retry 3

# Copy package.json and install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the rest of the application
COPY . .

# Set Rails environment
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Precompile assets (use a dummy secret key base for asset compilation)
RUN SECRET_KEY_BASE=dummy_secret_for_assets_precompilation \
    DATABASE_HOST=localhost \
    DATABASE_NAME=dummy \
    DATABASE_USER=dummy \
    DATABASE_PASSWORD=dummy \
    bundle exec rails assets:precompile

# Copy and set permissions for the entrypoint script
COPY bin/docker-entrypoint /usr/bin/docker-entrypoint
RUN chmod +x /usr/bin/docker-entrypoint

# Expose the port Koyeb will use (defaults to 8000, configurable via PORT)
EXPOSE 8000

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint"]

# Default command: start Puma server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
