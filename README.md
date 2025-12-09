# bash-libs
Generic libraries for Bash scripts

## Run tests against different versions of Bash using Docker

```
for bash_version in 3 4 5 latest
  do docker run --rm -it -v .:/source "bash:$bash_version" sh -c 'apk add bats && /source/run-tests.sh'
done
```
