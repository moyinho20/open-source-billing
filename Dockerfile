# Use an official Ruby runtime based on Alpine Linux as a parent image
FROM ruby:2.7-alpine

# Set environment variables
ENV RAILS_ENV=development
ENV RAILS_ROOT=/var/www/app

# Install dependencies
RUN apk update && apk add --no-cache \
  build-base \
  postgresql-dev \
  nodejs \
  yarn \
  shared-mime-info \
  libxml2-dev \
  libxslt-dev \
  gcompat
RUN apk update && apk add bash

# Create the app directory and set it as the working directory
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

# Install bundler
RUN gem install bundler -v 2.4.22

# Copy the Gemfile and Gemfile.lock into the working directory
COPY Gemfile Gemfile.lock ./

# Copy the rest of the application code
COPY . .

# Install the gems specified in the Gemfile
RUN bundle install

# Precompile assets for production
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose port 3000 to the Docker host
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
