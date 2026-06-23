#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

VERSIONS=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")

for version in "${VERSIONS[@]}"; do
    echo "=========================================="
    echo "Building and testing PHP version: $version"
    echo "=========================================="
    
    # Build image
    docker build --build-arg PHP_VERSION=$version -t jenkins-php-jnlp-slave:$version .
    
    # Run tests
    echo "Running tests for PHP $version..."
    
    docker run --rm --entrypoint java jenkins-php-jnlp-slave:$version -version > /dev/null
    docker run --rm --entrypoint java jenkins-php-jnlp-slave:$version -jar /usr/share/jenkins/agent.jar -version > /dev/null
    docker run --rm --entrypoint symfony jenkins-php-jnlp-slave:$version -V > /dev/null
    docker run --rm --entrypoint composer jenkins-php-jnlp-slave:$version -V > /dev/null
    
    # Xdebug test (note: some older versions might have it named slightly differently or disabled, let's verify if xdebug loads)
    docker run --rm --entrypoint php jenkins-php-jnlp-slave:$version -m | grep -qi xdebug
    
    # User verification
    docker run --rm --entrypoint whoami jenkins-php-jnlp-slave:$version | grep -q jenkins
    
    echo "PHP $version successfully built and verified!"
done

echo "=========================================="
echo "All PHP versions built and verified successfully!"
echo "=========================================="
