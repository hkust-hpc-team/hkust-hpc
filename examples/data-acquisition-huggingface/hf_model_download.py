from transformers import AutoModelForCausalLM, AutoTokenizer

model_id = "Qwen/Qwen2-0.5B"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(model_id)
print("Model loaded successfully!")
