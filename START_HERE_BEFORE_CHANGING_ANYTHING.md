# myHome
Container repository for all the tools I use in my home

To start everything...
    - docker compose -f docker-compose-blackbombe.yml --profile all up -d
To stop everything...
    - docker compose -f docker-compose-blackbombe.yml --profile all down

To start Plex
    - docker compose -f docker-compose-blackbombe.yml --profile media up -d
To stop Plex
    - docker compose -f docker-compose-blackbombe.yml --profile media down

To start the DVR bundle
    - docker compose -f docker-compose-blackbombe.yml --profile dvr up -d
To stop DVR bundle
    - docker compose -f docker-compose-blackbombe.yml --profile dvr down

To start Paperless library
    - docker compose -f docker-compose-blackbombe.yml --profile library up -d
To stop Paperless library
    - docker compose -f docker-compose-blackbombe.yml --profile library down

## To Use...
1. Create a new .env file for the machine. Use the .env-template files to start.
2. Make any directory changes (i.e. symlinks)


## Directory structure 
```
myhome/
  |- compose/
  |- docker/
  |- config/
  |- automation/ (files for home automation)
  |- library/ (media files for library)
  |- media/ (media files for plex/dvr)
  |- labs/ (files/projects for development)
  |- secrets/ (docker secrets files for sensitive information)
  |- transcode/
  |- .dockerignore
  |- .env 
  |- .gitignore
  |- docker-compose-blackbombe.yml
  |- docker-compose-bastion.yml
  |- docker-compose-obra-skai.yml
  |- START_HERE_BEFORE_CHANGING_ANYTHING.md
```

## Files/Directories

###### compose/
This directory contains all of the service compose files.

###### compose/defaults/
This directory contains all any default confirmations for the composes.

###### config/
This directory contains all of the data files created/used by the compose services.

###### media/
This directory is where you have keep your media files. This directory can be a sub-dir, a symlink, or a directory of symlinks.

###### labs/
This directory is where you keep your development projetcs.

###### library/
This directory is where you keep your documents.

###### gitignore files
Set to ignore the contents of...
- config/
- media/
- labs/
- library/
- secrets/
- .env

## Environment Variables
- MYHOME_DIR=/share/data
- PUID=1000
- PGID=100
- TZ=America/Los_Angeles

## Profiles
- all
- labs
- library
- dvr
- media



