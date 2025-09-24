import os
import shutil
import kagglehub

# Download dataset
path = kagglehub.dataset_download("zadafiyabhrami/global-crocodile-species-dataset")
print("Dataset downloaded to:", path)

# Ensure seeds folder exists
seeds_dir = os.path.join(os.path.dirname(__file__), "..", "seeds")
os.makedirs(seeds_dir, exist_ok=True)

# Copy first CSV file into seeds/public_data.csv
for file in os.listdir(path):
    if file.endswith(".csv"):
        src = os.path.join(path, file)
        dst = os.path.join(seeds_dir, "crocodile_species.csv")
        shutil.copy(src, dst)
        print(f"Copied {src} -> {dst}")
        break