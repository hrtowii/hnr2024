# hnr2024
## RSS Feed reader with sentiment analysis
* Currently hardcoded to CNA only
* Currently hardcoded to only 1 RSS feed from CNA
* Nothing is cached
* Preferences do not work
* Requires a server at localhost:5000 to be running for scraping CNA news feeds for previews, and for sentiment analysis

## Start python server for SA
### Requirements
`pip install flask transformers scipy`

### Starting server
`flask --app python/main run`

### How to use
Find the development server at http://127.0.0.1:5000

Send a `POST` request to `localhost/analyse` with a `JSON` input, passing a text field.

Example:
```
{
    "text": INPUT
}
```

The server will respond in the following format:
```
[
{ 
'label' : JUDGEMENT, '
score' : CONFIDENCE 
}
]
```
