import numpy as np
from fastembed import TextEmbedding

def cosine_sim(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

model = TextEmbedding(model_name="BAAI/bge-small-en-v1.5")
vec1 = list(model.embed(["لبن packaging: كرتونه"]))[0]
vec2 = list(model.embed(["Milk 1L carton (كرتونة لبن)"]))[0]
vec3 = list(model.embed(["لبن packaging: carton"]))[0]

print("Sim 1:", cosine_sim(vec1, vec2))
print("Sim 2:", cosine_sim(vec3, vec2))
