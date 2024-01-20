from flask import Flask, request, jsonify
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline
from scipy.special import softmax


# setting up my ai magic
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

if __name__ == "__main__":
    app.run()
