"""Sentiment-Klassifikation deutscher Texte ueber transformers.

Ersetzt die Bibliothek germansentiment: deren predict_sentiment() ruft
tokenizer.batch_encode_plus() auf, das in transformers 5 entfernt wurde.
germansentiment 1.1.0 ist die letzte Version und deklariert transformers
ohne Obergrenze — ein Fix upstream ist nicht zu erwarten.

Die Textbereinigung ist unveraendert aus germansentiment uebernommen, damit
die Ergebnisse fuer oliverguhr/german-sentiment-bert identisch bleiben. Sie
passt zum Vorverarbeitungsschema dieses Modells (Kleinschreibung, Ziffern als
Woerter, nur deutsche Buchstaben) und wuerde anderen Modellen schaden —
deshalb schaltet sie sich nur fuer dieses Modell automatisch ein.
"""

import re

import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer

DEFAULT_MODEL_NAME = "oliverguhr/german-sentiment-bert"

_CLEAN_CHARS = re.compile(r"[^A-Za-züöäÖÜÄß ]", re.MULTILINE)
_CLEAN_HTTP_URLS = re.compile(r"https*\S+", re.MULTILINE)
_CLEAN_AT_MENTIONS = re.compile(r"@\S+", re.MULTILINE)

_DIGIT_WORDS = {
    "0": " null", "1": " eins", "2": " zwei", "3": " drei", "4": " vier",
    "5": " fünf", "6": " sechs", "7": " sieben", "8": " acht", "9": " neun",
}


class SentimentModel:
    """Klassifiziert Texte und liefert Label und Wahrscheinlichkeiten.

    Die Signatur von predict_sentiment() entspricht der von germansentiment,
    damit der aufrufende R-Code unveraendert bleibt.
    """

    def __init__(self, model_name=DEFAULT_MODEL_NAME, clean_text=None):
        if clean_text is None:
            clean_text = model_name == DEFAULT_MODEL_NAME

        self.model_name = model_name
        self.clean = bool(clean_text)
        self.device = "cuda" if torch.cuda.is_available() else "cpu"

        self.model = AutoModelForSequenceClassification.from_pretrained(model_name)
        self.model = self.model.to(self.device).eval()
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)

    def clean_text(self, text):
        text = text.replace("\n", " ")
        text = _CLEAN_HTTP_URLS.sub("", text)
        text = _CLEAN_AT_MENTIONS.sub("", text)
        for digit, word in _DIGIT_WORDS.items():
            text = text.replace(digit, word)
        text = _CLEAN_CHARS.sub("", text)
        return " ".join(text.split()).strip().lower()

    def predict_sentiment(self, texts, output_probabilities=False):
        texts = list(texts)
        if self.clean:
            texts = [self.clean_text(text) for text in texts]

        # transformers 5 hat batch_encode_plus entfernt; der direkte Aufruf des
        # Tokenizers ist der dokumentierte Ersatz und liefert dieselbe Ausgabe.
        encoded = self.tokenizer(
            texts,
            padding=True,
            truncation=True,
            add_special_tokens=True,
            return_tensors="pt",
        ).to(self.device)

        with torch.no_grad():
            logits = self.model(**encoded).logits

        id2label = self.model.config.id2label
        labels = [id2label[i.item()] for i in torch.argmax(logits, axis=1)]

        if not output_probabilities:
            return labels

        probabilities = [
            [[id2label[index], value] for index, value in enumerate(row)]
            for row in torch.softmax(logits, dim=-1).tolist()
        ]
        return labels, probabilities
