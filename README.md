# Frikanalen upload receiver

This utility exposes a tusd endpoint.
Any user with a valid session key can upload to this endpoint.
Tusd uses hook scripts for integration.
I have chosen to write these in Python.

## Development

We use s3-ninja for testing, which emulates an S3 object store.

```bash
docker build -t upload-receiver .
docker run --env-file dev-env -p 1080:1080 --add-host=host.docker.internal:host-gateway upload-receiver
```

## Production

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: upload-receiver
stringData:
  AWS_ENDPOINT: http://s3-backend
  AWS_ACCESS_KEY_ID: (key-id)
  AWS_SECRET_ACCESS_KEY: (access-key)
  AWS_REGION: media-store
```

## Hoooks

The **pre-create** hook exits with return code 0 if the API at FK_API validates the user's session cookie.

The **post-finish** hook issues an HTTP call to the media processor, which validates/analyzes the file using ffprobe.
If the file passes validation, it POSTs the file to ${FK_API}/videos/media.
If the file is not possible to validate, it exits with non-zero return code, which is then propagated to the user.
