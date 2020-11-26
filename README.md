# Test-Sync
We have various requirements to sync things from one repo to another. Github does not currently support this. This repo has some examples of how we could achieve this. 

### Approach
Schedule a workflow in the downstream repo which runs hourly (?) and performs the sync that is required. 

If required, these workflows can be manually triggered if we have a pressing need for up to date info.
To manually trigger a workflow on github go to Actions -> Docs -> [RunWork flow](https://github.com/carlaKC/test-sync/actions?query=workflow%3ADocs)

### Use Cases
#### Docs Sync For Lightning Labs
Lightning Labs has docs folders scattered across its repos (lnd/loop/pool/faraday), which we would like to keep in a single repo for the sake of using gitbook use. We do not want to manually copy these docs over, or let them get out of sync, so it would be ideal for docs changes to sync immediately to the gitbook repo. 

Using the example of `loop`:
- Upstream repo: [Loop Repo](https://github.com/lightninglabs/loop)
- Downstream repo: [Documentation Repo](https://github.com/lightninglabs/docs.lightning.engineering)
- Action: Pull the loop repo, copy across the docs and commit them

#### Proto Generation
As is, we only generate the golang proto code for lnd (because we need it in regular dev). People who are looking to access our rpc server with other languages have to generate their own protos, which has proved to be a challenge for many folks. We don't want to clutter the lnd repo with a ton of proto files in different languages, so it would be ideal if we had protos which were maintained in another repo. 

- Upstream repo: lnd
- Downstream repo: a new protos repo
- Action: pull lnd, build protos, commit them to new repo

## Alternative: Webhooks
If we wanted to be OP and sync immediately, we could setup webhooks and a server to do this instantly, but it seems like overkill for our requirements. 

1. Webhook in upstream repo triggers on merge to master branch
2. Webhook hits the http server contained in this repo
3. The webhook server triggers a travis build (or github action?) in the downstream repo

