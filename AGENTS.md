# Project Guidelines

This project builds multi-version, multi-architecture Jenkins inbound agent (JNLP slave) Docker images tailored for PHP environments.

## Architecture

The project follows a layered Dockerfile strategy:
- **Base Layer**: Inherits from `fbraz3/php-cli:$PHP_VERSION` (supports PHP versions 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, and 8.4).
- **Jenkins Layer**: Imports agent binaries (`agent.jar`, `jenkins-agent` script) from official `jenkins/inbound-agent` via multi-stage COPY.
- **Tools**: Installs JRE (Java 17), Composer, Symfony CLI, MariaDB client, and Xdebug.
- **Permissions**: Re-maps the default `php` user (UID/GID 1000) from the base image to `jenkins` (UID/GID 1000) with home directory `/home/jenkins`.

## Build and Test

To verify the Dockerfile changes locally across all PHP versions before pushing or committing:
- Execute the test script: `./scripts/test_all_versions.sh`
- This script builds the images and runs a verification suite checking Java, agent.jar, Symfony CLI, Composer, Xdebug, and the active user.

If testing a single PHP version (e.g. 8.2), you can build and run verification manually:
```bash
docker build --build-arg PHP_VERSION=8.2 -t jenkins-php-jnlp-slave:8.2 .
docker run --rm --entrypoint php jenkins-php-jnlp-slave:8.2 -v
```

## Conventions

- **Layering**: Avoid adding package repositories or monolithic apt commands directly in the Dockerfile. Use `fbraz3/php-cli` as the foundation which already contains standard PHP extensions.
- **User Permissions**: Always run commands needing root privileges (e.g. `apt-get`, `usermod`, `chown`) before switching back to `USER jenkins`. The final instruction of the Dockerfile must be `USER jenkins`.
- **Workflow Strategy**: Use the single consolidated workflow [docker-images.yml](file:///.github/workflows/docker-images.yml) for GitHub Actions. It utilizes a matrix strategy to build, test, and push all PHP versions.
