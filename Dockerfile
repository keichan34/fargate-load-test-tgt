######################
# Stage: builder
FROM ruby:2.7.1-alpine as builder

RUN apk add --update --no-cache \
    build-base \
    git \
    nodejs-current \
    yarn \
    tzdata \
    python

WORKDIR /app

# Install gems
ADD Gemfile* /app/
RUN gem install bundler -v '2.1.2' --no-document \
    && bundle config --global frozen 1 \
    && bundle install --without development test -j4 --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete

# Add the Rails app
ADD . /app

# Remove folders not needed in resulting image
RUN rm -rf node_modules tmp/cache app/assets lib/assets spec test \
    && mkdir -p app/assets/config \
    && echo '{}' > app/assets/config/manifest.js

###############################
# Stage Final
FROM ruby:2.7.1-alpine

# Add Alpine packages
RUN apk add --update --no-cache \
    tzdata \
    file \
    openssh \
    bash \
    curl

# Add user
RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app
USER app

# Copy app with gems from former build stage
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /app /app

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV EXECJS_RUNTIME Disabled
ENV RAILS_ENV production

WORKDIR /app

# Expose Puma port
EXPOSE 3000

# Start up
CMD [ "bundle", "exec", "puma", "-C", "/app/config/puma.rb" ]
