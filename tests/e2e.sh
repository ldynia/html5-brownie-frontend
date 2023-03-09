#!/usr/bin/env bash

SUCCESS=0
FAILED=1

function test_response_code(){
  TEST_NAME="Test status code"

  STATUS_CODE=$(curl localhost:5000 \
  --head \
  --output /dev/null \
  --silent \
  --write-out '%{http_code}\n')

  if [ $STATUS_CODE == $1 ]; then
    echo "$TEST_NAME : Success"
    return $SUCCESS
  else
    echo "$TEST_NAME : Failed"
    return $FAILED
  fi
}

function test_body_content() {
  TEST_NAME="Test body content"
  # regex101.com Pattern <figcaption id="footer">some words</figcaption>
  MATCH=$(curl --silent localhost:5000 | grep -E '<figcaption id="footer">(\w.+)<\/figcaption>' | xargs echo -n)
  if [ ! -z "$MATCH" ]; then
    echo "$TEST_NAME : Success"
    return $SUCCESS
  else
    echo "$TEST_NAME : Failed"
    return $FAILED
  fi
}

# Run tests
test_response_code 200
test_body_content