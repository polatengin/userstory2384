SCRIPT_FILE=$1
BUILD_ID=$2

echo "
FROM ubuntu

RUN apt-get update

RUN apt-get install -y curl gnupg gnupg2 ca-certificates

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61
RUN echo \"deb https://dl.bintray.com/loadimpact/deb stable main\" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install k6

WORKDIR /k6

ADD ${SCRIPT_FILE} ./script.js

RUN printf \"#! /bin/bash\n\nk6 run ./script.js && curl -v 'https://enpolat-k6-testing.free.beeceptor.com/api/k6-test?build_id=${BUILD_ID}&part=$1'\" > run.sh

RUN chmod +x ./run.sh

ENTRYPOINT [\"./run.sh\", \"$PART\"]
" | docker build --tag enpolatacr.azurecr.io/k6:${BUILD_ID} -

docker push enpolatacr.azurecr.io/k6:${BUILD_ID}
