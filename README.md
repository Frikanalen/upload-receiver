# Frikanalen upload receiver

This utility exposes a tusd endpoint for user media uploads.

Once a file is uploaded, it's dropped into the watch folder of [frikanalen/ingest], which takes it from there.

## Development

```bash
# build local docker package
docker build -t upload-receiver .
# run it
docker run --net=host --env-file dev-env -p 1080 upload-receiver
```

## Hooks

**post-finish** copies to the ingest watch folder.
