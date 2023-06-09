# Development Setup

## ENV File & Micro Services

MOMENTVM runs on a micro service architecture.

This is why micro service connections have to be configured at boot time.

To make this convenient, the crendentials are stored in the rails credentials file and encrypted with the corresponding key.
Production secrets are not stored in there.

To set them up in your config file, configure the services endpoints you want to start with.

Keep in mind, if you use a mix of remote and local instances, versions might be off and you might experience issues.

.ENV File

```env
RENDER_INSTANCE = local
PUBLISH_INSTANCE = release
PROXY_INSTANCE = local
TRANSLATION_INSTANCE = release
S3_INSTANCE = release
```

## Quickstart

Run: `heroku local -f Procfile.dev`

## Notes

Once you run `heroku local` the processes according to `Procfile`is executed.
