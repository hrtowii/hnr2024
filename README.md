# hnr2024

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


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