---
title: "The complete guide to setup a CI/CD for Rails 5+ on Gitlab"
layout: post
date: 2018-08-15 20:12
image: /assets/images/post_cover/gitlab_ci_rails.jpg
headerImage: true
tag:
- code
- programming
- rails
- gitlab
blog: true
author: zimski
description: The complete guide to setup a CI/CD for Rails 5+ on Gitlab
---

# Continuous Integration/Deployment for Rails on Gitlab
![Gitlab piplines](/assets/images/pipline_green.png){:class="img-responsive"}

In this blog post, we will through the necessary steps to setup Gitlab in order
to run Rails build, tests & deployment if everything will be okay.
I will put a particular attention on `rails system test` and how to make them works.

We will use Heroku to deploy our staging App.

# What will we achieve ?

## The build Stage

The build will contain:
- Installation of dependencies
- Database setup
- Precompile of assets (assets & webpacker)


## The Test Stage

### The Integration tests
In this stage, we will run all our integration tests, which basically turn to
run:
`bundle exec rails test`

### The system tests

This is the most exciting and important part to have in our CI.
The system tests are very useful in term of testing complex UI requiring a massive use
of Javascript (React of Vue app) and interacting with external services like `Google
Map Places`.

The system test will mimic a regular user by clicking and filling inputs like a regular user on our App.
The main command executed in this stage is `bundle exec rails test:system`.

The interacting fact in this case is the use of container to embed the `Selenium
Chrome browser` to run real browser to fetch and tests our frontend.

## The deploy Stage
This is an easy step, we will deploy our application to the staging environment.

-----------------------

# The GITLAB-CI

Gitlab offer to everyone ( and we should be grateful to them for all the work
that have be done) a recipe that define how the code will be tested / deployed
and all the services needed for these tasks.
All the instructions are stored in `.gitlab-ci` present in the root of our repo.

This offer us a *centralized* and an *easy way* to manage our source code and
our continues integration for `FREE`.

## How does it works

The CI follow these simple steps:
1. Booting one or several containers aka `services` that you have specified in the `.gitlab-ci`
2. Copy your repo in the main container.
3. Run all scripts wanted in it

## Use the cache to speedup the CI
Gitlab allows us to cache folders and files and use them for the next jobs.
No need to recompile all dependencies or even download them.
In our case, caching all the `gems` and `node_modules` will save us several minutes.

## Use artifacts to debug our tests
When the system tests fails, the test will save the `screenshots` in a `temp` folder.

The `artifacts` make possible for us to save those files and tie them to the job.

This will help us a lot when we want to debug a failing system tests.


--------------------
# Let's do it

## 1. The build

### Prepare the build container

The build will be executed in a container, so we should have a container with
all the dependencies needed bundled inside.

For the modern rails app we should include:
- Ruby
- Node + Yarn
- Some system libraries

Here is the `dockerfile`

```bash
FROM ruby:2.4.3

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qqy && apt-get install  -qqyy yarn nodejs postgresql postgresql-contrib libpq-dev cmake

RUN rm -rf /var/lib/apt/lists/*
```

Easy yay !

Now, we should publish this container to enable GitlabCI to use it.

`Gitlab` provide for us a container registry ! for free again !

So we just need to push this container in the project registry.

First, you should login to gitlab registry

```bash
docker login registry.gitlab.com
# use your gitlab credential
```

and PUSH

```bash
docker push registry.gitlab.com/[ORG]/[REPO]/[CONTAINER]:v1 # v1 is my version tag
```

If you have `ADSL` internet connection with a poor uploading speed, you can go
take a nap ;)

Once the push finishes, we are good to go to the next step.

### The build script
This is the main build part in the gitlab-ci file

```yaml
image: "registry.gitlab.com/[ORG]/[REPO]/[CONTAINER]:v1"

variables:
  LC_ALL: C.UTF-8
  LANG: en_US.UTF-8
  LANGUAGE: en_US.UTF-8
  RAILS_ENV: "test"
  POSTGRES_DB: test_db
  POSTGRES_USER: runner
  POSTGRES_PASSWORD: ""

# cache gems and node_modules for next usage
.default-cache: &default-cache
  cache:
    untracked: true
    key: my-project-key-5.2
    paths:
      - node_modules/
      - vendor/
      - public/

build:
  <<: *default-cache
  services:
    - postgres:latest
  stage: build
  script:
  - ruby -v
  - node -v
  - yarn --version
  - which ruby
  - gem install bundler  --no-ri --no-rdoc
  - bundle install  --jobs $(nproc) "${FLAGS[@]}" --path=vendor
  - yarn install
  - cp config/database.gitlab config/database.yml
  - RAILS_ENV=test bundle exec rake db:create db:schema:load
  - RAILS_ENV=test bundle exec rails assets:precompile
```

So we are using the previously created image to host the build.

We should add to the project a `config/database.gitlab` to replace the original
database config and use custom host and credential to connect to postgres
container booted by the GitlabCI.

```yaml
  services:
    - postgres:latest
```

Gitlab when reading this line will bootup a database container (postgress) and
will use the variables defined before to setup the database

```bash
  POSTGRES_DB: test_db
  POSTGRES_USER: runner
  POSTGRES_PASSWORD: ""
```

The `config/database.gitlab` will tell our rails app how to connect to the
database, so before the app boots, the `database.yml` will be replaced by the
custom one.

```yaml
test:
  adapter: postgresql
  encoding: unicode
  pool: 5
  timeout: 5000
  host: postgres
  username: runner
  password: ""
  database: test_db
```

## 2. The Integration Tests script
No need more explanation for this

```yaml
integration_test:
  <<: *default-cache
  stage: test
  services:
    - postgres:latest
    - redis:alpine
  script:
    - gem install bundler  --no-ri --no-rdoc
    - bundle install  --jobs $(nproc) "${FLAGS[@]}" --path=vendor
    - cp config/database.gitlab config/database.yml
    - bundle install --jobs $(nproc) "${FLAGS[@]}" --path=vendor
    - RAILS_ENV=test bundle exec rake db:create db:schema:load
    - RAILS_ENV=test bundle exec rails assets:precompile
    - bundle exec rake test

```

## 3. The System Tests script

The infrastructure to make possible the system test is quite interesting.

To run the test we should start a browser (in a container) and fetch the page
from the rails server (from an other container).


![System tests & containers](/assets/images/system_tests.png){:class="img-responsive"}

```yaml
system_test:
  <<: *default-cache
  stage: test
  services:
    - postgres:latest
    - redis:alpine
    - selenium/standalone-chrome:latest
  script:
    - gem install bundler  --no-ri --no-rdoc
    - bundle install  --jobs $(nproc) "${FLAGS[@]}" --path=vendor
    - cp config/database.gitlab config/database.yml
    - export selenium_remote_url="http://selenium__standalone-chrome:4444/wd/hub/"
    - bundle install  --jobs $(nproc) "${FLAGS[@]}" --path=vendor
    - RAILS_ENV=test bundle exec rake db:create db:schema:load
    - RAILS_ENV=test bundle exec rails assets:precompile
    - bundle exec rake test:system
  artifacts:
    when: on_failure
    paths:
      - tmp/screenshots/
```

We should tell to capybara to use the right `IP` instead of `localhost`, because here we have the browser
and the server in two different containers.

In the `environment/test.rb`, add these lines

```ruby
  net = Socket.ip_address_list.detect{|addr| addr.ipv4_private? }
  ip = net.nil? ? 'localhost' : net.ip_address
  config.domain = ip
  config.action_mailer.default_url_options = { :host => config.domain }

  Capybara.server_port = 8200
  Capybara.server_host = ip
```

The `rails system test` will take screenshots and save them to `tmp/screenshots`

![System tests & scrennshots](/assets/images/screenshots.png){:class="img-responsive"}

As you can see, the screenshots are stored and attached to job, Neat!

## 4. Staging deployment

This will deploy our code if `build` and `tests` stages succeed.

```
deploy_staging:
  stage: deploy
  variables:
    HEROKU_APP_NAME: YOUR_HEROKU_APP_NAME
  dependencies:
    - integration_test
    - system_test
  only:
    - master
  script:
    - gem install dpl
    - dpl --provider=heroku --app=$HEROKU_APP_NAME --api-key=$HEROKU_API_KEY
```

The `HEROKU_API_KEY` is stored in a safe place in the settings of the project

![Gitlab CI variables](/assets/images/gitlab_variables.png){:class="img-responsive"}

For more information about this, go to [Gitlab variables documentation](https://docs.gitlab.com/ee/ci/variables/)


-------------
# Conclusion

`Gitlab` is an amazing project and provide a very nice spot where everything is
well integrated, the coding experience is enhanced.

Finally, let's hope that the migration to `Google compute engine` will provide a
better robustness to the project and less issues.

> Longue vie à Gitlab !!

Cheers!

Here is the complete `Gitlab CI`
<script src="https://gitlab.com/snippets/1745898.js"></script>
