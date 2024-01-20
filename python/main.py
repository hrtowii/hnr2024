from flask import Flask, request, jsonify
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline
from scipy.special import softmax
from urllib.parse import urlparse
import urllib.request
from bs4 import BeautifulSoup

MODEL = f"cardiffnlp/twitter-roberta-base-sentiment"
tokenizer = AutoTokenizer.from_pretrained(MODEL)
model = AutoModelForSequenceClassification.from_pretrained(MODEL)
sent_pipeline = pipeline("sentiment-analysis", model=model, tokenizer=tokenizer)
DEFINITIONS = {
    'LABEL_0': 'NEGATIVE',
    'LABEL_1': 'NEUTRAL',
    'LABEL_2': 'POSITIVE'
}

app = Flask(__name__)

# input: string
# output: list
# output structure: [{ 'label' : JUDGEMENT, 'score' : CONFIDENCE }]
def query_model(input):
    result = sent_pipeline(input)
    result[0]['label'] = DEFINITIONS[result[0]['label']]
    return result


@app.route('/analyse', methods=["POST"])
def analyse():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400
    
    data = request.json
    text = data.get("text")
    if not text:
        return jsonify({"error": "No text provided"}), 400

    print(data)
    text = data["text"]

    score = query_model(text)
    label, score = score[0]['label'], score[0]['score']
    return jsonify({ "label" : label, "score" : score })

@app.route('/analyse_batch', methods=["POST"])
def analyse_batch():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 422
    data = request.json
    texts = data.get("texts")
    if not texts:
        return jsonify({"error": "No texts provided"}), 422

    res = []

    texts = data["texts"]
    for text in texts:
        score = query_model(text)
        label, score = score[0]['label'], score[0]['score']
        res.append({ "label" : label, "score" : score })
    return jsonify(res)

@app.route('/scrape', methods=["POST"])
def scrape():
    headers = {'User-Agent': 'Mozilla/5.0'}

    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.json
    url = data.get("url")

    if not url or not urlparse(url):
        return jsonify({"error": "Not valid URL"}), 400

    try:
        # Fetch the webpage content
        page = urllib.request.urlopen(url)
        bbytes = page.read()

        # Parse HTML content using BeautifulSoup
        soup = BeautifulSoup(bbytes.decode("utf8"), "html.parser")

        # Find elements with classes 'text' and 'text-long' and extract all <p> tags
        relevant_elements = soup.find_all(class_=['text', 'text-long'])
        paragraphs = []

        for element in relevant_elements:
            # Extract text from <p> tags within the identified elements
            paragraphs.extend(element.find_all('p'))

        # Combine text from identified <p> tags
        news_text = ' '.join([paragraph.get_text() for paragraph in paragraphs])

        # Shorten the text to 100 words
        shortened_text = ' '.join(news_text.split()[:100])

        return jsonify({"news": shortened_text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
if __name__ == "__main__":
    app.run()
