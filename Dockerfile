FROM ruby:2.3.1

RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \ 
    postgresql-client \
    nodejs \
		&& apt-get -q clean \ 
		&& rm -rf /var/lib/apt/lists

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN sudo apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev
RUN sudo gem install nokogiri
RUN bundle install
COPY . .

CMD bundle exec unicorn -c ./config/unicorn.rb