# Project Guidelines

This project builds multi-version, multi-architecture Jenkins inbound agent (JNLP slave) Docker images tailored for PHP environments.

## Architecture

The project follows a layered Dockerfile strategy:
- **Base Layer**: Inherits from `fbraz3/php-cli:$PHP_VERSION` (Ubuntu 22.04 base).
- **Jenkins Layer**: Imports agent binaries (`agent.jar`, `jenkins-agent` script) from official `jenkins/inbound-agent` via multi-stage COPY.
- **Tools**: Installs JRE (Java 17), Composer, Symfony CLI, MariaDB client, and Xdebug.
- **Permissions**: Re-maps the default `php` user (UID/GID 1000) from the base image to `jenkins` (UID/GID 1000) with home directory `/home/jenkins`.

## Build and Test

To verify the Dockerfile changes locally across all PHP versions before pushing or committing:
- Execute the test script: `./scripts/test_all_versions.sh`
- This script builds the images and runs a verification suite (checks Java, agent.jar, Symfony CLI, Composer, Xdebug, and active user).

## Conventions

- **Layering**: Avoid adding package repositories or monolithic apt commands directly in the Dockerfile. Use `fbraz3/php-cli` as the foundation which already contains standard PHP extensions.
- **User Permissions**: Always run commands needing root privileges (e.g. `apt-get`, `usermod`) before switching back to `USER jenkins`. The final instruction of the Dockerfile must be `USER jenkins`.
- **Workflow Strategy**: Use the single consolidated workflow [docker-images.yml](file:///.github/workflows/docker-images.yml) for GitHub Actions. It utilizes a matrix strategy to build, test, and push all PHP versions.
