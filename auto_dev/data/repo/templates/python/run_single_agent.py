"""
Template file for the the scripts/run_single_agent.sh file

"""
EXTENSION = ".sh"
TEMPLATE = """
set -e 

# fetch the agent from the local package registry
aea fetch $1 --local --alias agent

# go to the new agent
cd agent

# install the agent
aea install

# create and add a new ethereum key
aea generate-key ethereum && aea add-key ethereum

# install any agent deps
aea install

# issue certificates for agent peer-to-peer communications
aea issue-certificates

# finally, run the agent
aea run
"""
DIR = "./scripts/"
