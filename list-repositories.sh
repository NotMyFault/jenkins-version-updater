#!/bin/bash

# Set the GitHub organization and search query
ORG="jenkinsci"
QUERY="hamcrest-core+extension:xml+org:$ORG"

if [[ -z ${GITHUB_TOKEN} ]]; then
  echo 'Error: the GITHUB_TOKEN env var is not set.' >&2
  exit 1
fi

# Set the initial page number and total count
PAGE=1
TOTAL_COUNT=0

# Initialize an empty array to store repository names
repos=()

# Fetch all pages of results
while true; do
  # Make the API request to search for repositories
  response=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/search/code?q=$QUERY&page=$PAGE")

  # Extract repository names from the current page and append to the array
  repos+=($(echo "$response" | jq -r '.items[].repository.full_name'))

  # Get the total count of results from the first page
  if [ $PAGE -eq 1 ]; then
    TOTAL_COUNT=$(echo "$response" | jq -r '.total_count')
  fi

  # Increment the page number
  PAGE=$((PAGE + 1))

  # Break the loop if we have retrieved all results
  if (( PAGE > (TOTAL_COUNT / 30) + 1 )); then
    break
  fi
done

# Print the repository names
for repo in "${repos[@]}"; do
  echo "- $repo"
done
