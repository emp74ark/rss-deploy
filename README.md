# RSS deployment

## Dev environment

### Prerequisites

- Docker
- Ports 27020 and 3600 aren't in use

#### Sidenotes

- `docker compose` is part of the Docker CLI (docker) since version 1.27.0;
- `docker-compose` is a standalone tool that was used historically to define and manage multi-container Docker
  applications;
  In the context of this document there is no difference in these two tools, so if there is no docker compose in your
  system for some reason - use docker-compose tool (install it from the [GitHub](https://github.com/docker/compose), if
  it not available).

# Deploy

## Local Environment

Clone the following repositories:

- Frontend https://github.com/emp74ark/rss-angular
- Backend https://github.com/emp74ark/rss-nest

Keep the folders with these repositories at the same file system level.

```shell
docker compose -p rss -f compose.local.yaml up -d
```

Application environment variables for the backend should be stored in a `.env` file. Check
the `.env.example` in the _backend_ repository.

**NB!**: The domain names that containers use to communicate with each other are:

- MongoDB: rss-db
- Backend: rss-nest
- Frontend: rss-angular

To connect to the _MongoDB_, for example, the connection string should look like:
`mongodb://rss-db/rss`

### Potential Problems

- Access denied to the `node_modules` folder might be caused by Docker creating it with root permissions on Unix
  systems. The solution is to change the folder permissions: `chmod -R 777 ./node_modules` or delete it and run the node
  modules installation again.
- The Docker image is failing to run properly due to the port being in use by another application. To resolve this,
  stop any application that is using ports 27020 (not 27017), 3600.
