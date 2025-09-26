import os

final_models_path = r"C:\Users\ianth\OneDrive\Desktop\untitled\Emilys-Suprise\emily's-suprise-(ians-eyes-only)\Models\Final Models"

for root, dirs, files in os.walk(final_models_path):
    for file in files:
        if file.lower().endswith(".tres"):  # case-insensitive match
            file_path = os.path.join(root, file)
            try:
                os.remove(file_path)
                print(f"Deleted: {file_path}")
            except Exception as e:
                print(f"Failed to delete {file_path}: {e}")

print("Done.")