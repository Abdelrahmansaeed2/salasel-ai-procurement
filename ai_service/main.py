from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import json
import logging
from groq import Groq
from dotenv import load_dotenv

# LangChain Imports for RAG
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.documents import Document

# ==========================================
# 1. SETUP & CONFIGURATION
# ==========================================
load_dotenv() # Load variables from .env
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("Salasel-AI-Agent")

app = FastAPI(title="Salasel AI Microservice - Trinity Strategy")

GROQ_API_KEY = os.environ.get("GROQ_API_KEY")
client = Groq(api_key=GROQ_API_KEY)

# ==========================================
# 2. PYDANTIC MODELS (Strict Schemas)
# ==========================================
class VoiceOrderRequest(BaseModel):
    transcribed_text: str

class ExtractedOrder(BaseModel):
    intent: str
    item: str
    quantity: int
    urgency: str
    confidence_score: float

class PurchaseOrderDraft(BaseModel):
    status: str
    extracted_data: ExtractedOrder
    rag_specifications: str
    fraud_flag: bool
    requires_human_verification: bool
    message: str

# ==========================================
# 3. RAG LAYER (Knowledge)
# ==========================================
embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

def initialize_rag_database():
    try:
        # Mocking catalog data. Later, use PyPDFLoader here to read from the 'catalogs' folder.
        mock_docs = [
            Document(page_content="Cooking Oil (زيت قلي): 1 Liter bottles, SKU: OIL-100, Min order: 10 boxes. Supplier notes: Delivery takes 24 hours."),
            Document(page_content="Sugar (سكر): 1 KG bags, SKU: SUG-500, Min order: 50 bags. Supplier notes: High stock available.")
        ]
        vector_store = FAISS.from_documents(mock_docs, embeddings)
        logger.info("RAG Vector Store initialized successfully.")
        return vector_store
    except Exception as e:
        logger.error(f"Failed to init RAG: {e}")
        return None

vector_db = initialize_rag_database()

def retrieve_product_specs(item_name: str) -> str:
    """Queries the unstructured PDF/Catalog data to ground the LLM."""
    if not vector_db:
        return "Catalog data unavailable."
    
    docs = vector_db.similarity_search(item_name, k=1)
    if docs:
        return docs[0].page_content
    return "No specific catalog matching found."

# ==========================================
# 4. LLM LAYER (Intelligence)
# ==========================================
def extract_entities_with_llm(text: str) -> dict:
    """Calls Llama 3 8B to parse Egyptian Arabic text into strictly formatted JSON."""
    prompt = f"""
    You are an AI assistant for 'Salasel', a B2B supply chain app in Egypt.
    Process the following transcribed Egyptian Arabic voice note.
    Extract the entities and return ONLY a valid JSON object. Do not include markdown formatting or explanations.
    
    Schema required:
    {{
        "intent": "purchase_order",
        "item": "string (translated to standard English)",
        "quantity": integer,
        "urgency": "low|medium|high",
        "confidence_score": float (between 0.0 and 1.0 based on your certainty of the extraction)
    }}
    
    Text: "{text}"
    """
    
    chat_completion = client.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        model="llama-3.1-8b-instant",
        temperature=0.1,
        response_format={"type": "json_object"}
    )
    
    return json.loads(chat_completion.choices[0].message.content)

# ==========================================
# 5. AGENT ACTION LAYER (Action & Workflow)
# ==========================================
def fraud_and_validation_check(order: ExtractedOrder) -> bool:
    """Deterministic business rules for fraud prevention."""
    is_fraudulent = False
    if order.quantity > 5000:
        logger.warning(f"Fraud Alert: Unusually high quantity requested ({order.quantity}).")
        is_fraudulent = True
    if order.intent != "purchase_order":
        logger.warning("Validation Alert: Intent is not a purchase order.")
        is_fraudulent = True
    return is_fraudulent

@app.post("/process-voice-order", response_model=PurchaseOrderDraft)
async def agentic_procurement_workflow(request: VoiceOrderRequest):
    """The Orchestrator Agent."""
    max_retries = 3
    extracted_data = None
    
    for attempt in range(max_retries):
        try:
            raw_json = extract_entities_with_llm(request.transcribed_text)
            extracted_data = ExtractedOrder(**raw_json)
            
            if extracted_data.confidence_score < 0.75:
                logger.warning(f"Attempt {attempt + 1}: Confidence too low ({extracted_data.confidence_score}). Retrying...")
                continue 
            break 
            
        except Exception as e:
            logger.error(f"Attempt {attempt + 1} extraction failed: {e}")
            if attempt == max_retries - 1:
                raise HTTPException(status_code=400, detail="Agent failed to extract data.")

    if not extracted_data:
        raise HTTPException(status_code=400, detail="Extraction failed due to low confidence threshold.")

    catalog_specs = retrieve_product_specs(extracted_data.item)
    fraud_flag = fraud_and_validation_check(extracted_data)

    draft_po = PurchaseOrderDraft(
        status="Drafted - Awaiting Manual Confirmation",
        extracted_data=extracted_data,
        rag_specifications=catalog_specs,
        fraud_flag=fraud_flag,
        requires_human_verification=True,
        message="Order drafted successfully. Please review the UI and confirm to execute the SQL transaction."
    )
    
    return draft_po
