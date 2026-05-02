from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import io
import PyPDF2
import docx2txt

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- ML MODELS ----------------
model = joblib.load("model.pkl")
vectorizer = joblib.load("vectorizer.pkl")


# ---------------- DATA ----------------
SKILLS_DB = ["python", "ml", "ai", "sql", "java", "flutter", "dart"]


# ---------------- REQUEST MODEL ----------------
class Answer(BaseModel):
    question: str
    answer: str


# ---------------- TEXT EXTRACTION ----------------
def extract_text(file_bytes, filename):
    if filename.endswith(".pdf"):
        reader = PyPDF2.PdfReader(io.BytesIO(file_bytes))
        return "".join([p.extract_text() or "" for p in reader.pages])

    if filename.endswith(".docx"):
        return docx2txt.process(io.BytesIO(file_bytes))

    return ""


# ---------------- ATS + SKILLS ----------------
def get_skills(text):
    text = text.lower()
    return [s for s in SKILLS_DB if s in text]


def ats_score(pred, text):
    return min(100, int(len(text.split()) / 8 + pred * 60))


# ---------------- QUESTIONS ----------------
def generate_questions(skills):
    q = []

    for s in skills:
        if s == "python":
            q.append("Explain Python OOP concepts")
        elif s == "ml":
            q.append("What is overfitting in ML?")
        elif s == "sql":
            q.append("Explain SQL joins")
        else:
            q.append(f"Explain your experience in {s}")

    if not q:
        q = ["Tell me about yourself", "Explain your project"]

    return q


# ---------------- ANSWER SCORING ----------------
KEYWORDS = {
    "python": ["class", "object", "function", "oop"],
    "ml": ["model", "training", "dataset", "accuracy", "overfitting"],
    "sql": ["select", "join", "table", "query"]
}


def evaluate_answer(question, answer):
    score = 0
    answer = answer.lower()

    for key, words in KEYWORDS.items():
        if key in question.lower():
            for w in words:
                if w in answer:
                    score += 15

    score += min(len(answer.split()) // 2, 20)

    return min(score, 100)


# ---------------- API 1: RESUME ----------------
@app.post("/analyze-resume")
async def analyze(file: UploadFile = File(...)):

    data = await file.read()
    text = extract_text(data, file.filename)

    vec = vectorizer.transform([text])
    pred = model.predict(vec)[0]

    skills = get_skills(text)

    return {
        "ats_score": ats_score(pred, text),
        "skills": skills
    }


# ---------------- API 2: QUESTIONS ----------------
@app.post("/questions")
def get_questions(data: dict):
    return {
        "questions": generate_questions(data["skills"])
    }


# ---------------- API 3: EVALUATION ----------------
@app.post("/evaluate")
def evaluate(data: Answer):

    score = evaluate_answer(data.question, data.answer)

    return {
        "score": score,
        "feedback": "Good answer" if score > 60 else "Needs improvement"
    }