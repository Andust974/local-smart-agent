import os
from datasets import load_dataset
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from peft import LoraConfig, get_peft_model
from trl import SFTTrainer

base=os.environ.get("BASE_MODEL","TinyLlama/TinyLlama-1.1B-Chat-v1.0")
tok=AutoTokenizer.from_pretrained(base); tok.pad_token=tok.eos_token
model=AutoModelForCausalLM.from_pretrained(base)
peft=LoraConfig(r=8,lora_alpha=16,lora_dropout=0.05,target_modules=["q_proj","v_proj","k_proj","o_proj"])
model=get_peft_model(model, peft)

ds_tr=load_dataset("json", data_files="selftrain/lora/dataset/train.jsonl", split="train")
ds_ev=load_dataset("json", data_files="selftrain/lora/dataset/eval.jsonl",  split="train")

args=TrainingArguments(
    output_dir="selftrain/lora/models/lora_v1",
    per_device_train_batch_size=2, per_device_eval_batch_size=2,
    gradient_accumulation_steps=8, num_train_epochs=1, learning_rate=2e-4,
    logging_steps=50, save_steps=200, save_total_limit=2
)

trainer=SFTTrainer(
    model=model, tokenizer=tok,
    train_dataset=ds_tr, eval_dataset=ds_ev,
    formatting_func=lambda e:[f"Инструкция: {p}\nОтвет: {r}" for p,r in zip(e['prompt'],e['response'])],
    max_seq_length=1024, args=args
)
trainer.train(); trainer.save_model("selftrain/lora/models/lora_v1")
print("saved: selftrain/lora/models/lora_v1")
