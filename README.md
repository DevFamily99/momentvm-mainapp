# MOMENTVM CONTENT MANAGEMENT

Anomymize users via `rails db:anonymize_users`

## Basic setup

Note: We use `.env` for local environment variables.

Default user pw: admin admin

## Local development setup

- WebProxy rails s -p 1234
- Translation service rails s -p 6789
- RenderService vapor run serve (will default to 8080)

## Services

- RenderService
  Takes module body and template and returns rendered (unlocalized) html

- ProxyService
  Proxies a given url and puts a `__WIDGET__` placeholder in, so the live preview can be done

## Architecture at-a-glance

Each module has a body, which is basically the data for it. Using the schema, this can be edited using JSON Editor once clicking a module.
Each module also has a template. It's body is actual template code. Each template furthermore has a schema. The schema's body is yaml, once parsed to JSON, can be read by JSONEditor in order to generate an easy to use form to fill in the data.

## Previewing Flow

_Note: Live preview is done by the CMS_

### Rendering the modules

CMS will call `Pages#render` for html using a timestamp which the user can select via a control.
This will determine the preview for the given time.

`Pages#render` then determines which of its modules have an valid time stamp for the given date and return an array of page_modules.

### RenderService

Each module is then sent to the RenderService to generate actual html.

_Note: See RenderService for more information_

In detail, it will send the module body (data) and the template to RenderService.

At this point, localizations are still in the form of `::localize:1234::` (where 1234 is the translation ID) and will be localized at a later stage.

Then `Pages#render` will render two partials, one which is a helper for the live preview (js requires etc) and the other is a thin wrapper where the page modules will be inserted. Note that after this step, each module gets wrapped in its own `div` with index etc.

### TranslationService

This rendered string will then be passed to `TranslationService`.

The translations themselves live entirely in `TranslationService`'s database.

### ProxyService

Then proxy service is called which returns a html body with a placeholder, where the content will go. The modules are inserted and the whole page is returned

Back in `Pages#render_page` the page is passed to `render`.

## Web Services Security

All services authenticate using simple auth. The configuration is set in Heroku variables.

## Services in Detail

### TranslationService

Endpoint: `/translate_body`
URL params: `locale=de-DE`

body: The rendered html as text with `loc::1234` placeholders.

TranlsationService will try to find a `Translation` for the given locale and ID. If it finds a Translation for the given ID, it will go through the locale hierarchy (e.g. `de-DE` > `de` > `default`) to find the proper translation.

This means that each text line can be maintained independently, meaning it is a good idea to generally maintain translations on a language level (`de`) but some can be more specific and thus be maintained on the site level (`de-DE`).

## Velocity

```
#set($dateList =  ['2017-08-08',  '2017-08-09'])
#if( $dateList.contains($date.get('yyyy-MM-dd')) )
    contained
#else
    not contained
#end
```

## Features:

- Settings: One defined setting is the `locales-mapping` which defines to which locales the CMS will map to. Remember the translation engine will do the "right" thing anyway e.g. fall back to default for non-found locales or fall back to language level if site level is not specified in the translation body

## PublishingManifest

rails g model PublishingManifest page:references publishing_target:references creator:references
