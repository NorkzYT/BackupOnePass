# Contributing to BackupOnePass

Contributions are what make the open source community such a fantastic place to learn, inspire, and innovate. Any contributions you make are **very much appreciated**.

## Getting started

Thank you for your interest in BackupOnePass and your willingness to contribute!

We encourage you to explore the existing [issues](https://github.com/NorkzYT/BackupOnePass/issues) to see how you can make a meaningful impact. This document will help you setup your development environment.

### Install dependencies

You will need to install and configure the following dependencies on your linux machine:

- [Git](http://git-scm.com/)
- [Node.js v18.x (LTS)](http://nodejs.org)
- [Docker & Docker Compose](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository) latest
- [python](https://www.python.org/downloads/) latest 
- [npm](https://www.npmjs.com/) latest
- [Bun](https://bun.sh/) latest (Install with `npm install -g bun`)
- [GNU Make](https://www.gnu.org/software/make/) latest (Install with `sudo apt-get install make -y`).

## Local development

### Fork the repo

To contribute code, you must fork the [BackupOnePass repo](https://github.com/NorkzYT/BackupOnePass).

### Fork the repo

1. Clone your GitHub forked repo:

   ```sh
   git clone https://github.com/<github_username>/BackupOnePass.git
   ```

2. Go to the BackupOnePass directory:
   ```sh
   cd BackupOnePass
   ```

### Install dependencies

1. Install the dependencies in the root of the repo.

   ```sh
   bun run i # install dependencies
   ```

#### Get Started

1. Duplicate the `.env.example` file, naming the copy `.env`. Complete the necessary information within `.env`.

2. Run the following command.
   ```sh
   make run # Sets up and runs docker service
   ```


## Create a pull request

After making any changes, open a pull request. Once you submit your pull request, @NorkzYT will review it with you.

## Issue assignment

We do not have a process for assigning issues to contributors. Please feel free to jump into any issues in this repo that you are able to help with. Our intention is to encourage anyone to help without feeling burdened by an assigned task. Life can sometimes get in the way, and we do not want to leave contributors feeling obligated to complete issues when they may have limited time or unexpected commitments.

We also recognize that not having a process can sometimes lead to competing or duplicate PRs. There's no perfect solution here. We encourage you to communicate early and often on an Issue to indicate that you're actively working on it. If you see that an Issue already has a PR, try working with that author instead of drafting your own.

We review PRs in the order of their submission. We try to accept the earliest one that is closest to being ready to merge.
