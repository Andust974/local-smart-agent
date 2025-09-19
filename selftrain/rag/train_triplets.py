import json, random, os
from datasets import Dataset
from sentence_transformers import SentenceTransformer, losses, InputExample
from torch.utils.data import DataLoader

triplets="selftrain/rag/dataset/rag_triplets.jsonl"
outdir="selftrain/rag/models/emb_v1"
os.makedirs(outdir, exist_ok=True)

data=[]
with open(triplets,"r",encoding="utf-8") as f:
    for ln in f:
        o=json.loads(ln)
        if o.get("query") and o.get("positive") and o.get("negatives"):
            data.append(InputExample(texts=[o["query"], o["positive"], o["negatives"][0]]))

model=SentenceTransformer("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")
train_loader=DataLoader(data, shuffle=True, batch_size=8)
train_loss=losses.TripletLoss(model)
model.fit(train_objectives=[(train_loader, train_loss)], epochs=1, warmup_steps=100, output_path=outdir)
print("saved:", outdir)
