#!/bin/bash

export TASKCLUSTER_ACCESS_TOKEN=$(pass show community-tc/root | head -1)
export TASKCLUSTER_CLIENT_ID=$(pass show community-tc/root | tail -1)
export TASKCLUSTER_ROOT_URL=https://community-tc.services.mozilla.com
