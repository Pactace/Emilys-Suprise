import os
import shutil

export_path = r"C:\Users\ianth\OneDrive\Desktop\untitled\Emilys-Suprise\Models For Game"
import_path = r"C:\Users\ianth\OneDrive\Desktop\untitled\Emilys-Suprise\emily's-suprise-(ians-eyes-only)\Models\Final Models"

def unique_name(dest_folder: str, file_name: str) -> str:
	"""
	Return a file path inside dest_folder that does not already exist.
	If file_name exists, append a number before the extension: name1.png, name2.png, etc.
	"""
	name, ext = os.path.splitext(file_name)
	counter = 1
	new_name = file_name
	while os.path.exists(os.path.join(dest_folder, new_name)):
		new_name = f"{name}{counter}{ext}"
		counter += 1
	return os.path.join(dest_folder, new_name)

counter = 0
for folder in os.listdir(import_path):
	# Only look at folders with "Textures" in the name
	if "Textures" in folder:
		textures_folder = os.path.join(import_path, folder)
		if not os.path.isdir(textures_folder):
			continue

		# Remove "Textures" to get the base scene name
		base_name = folder.replace("Textures", "")

		# Recursively walk through every subfolder of export_path
		for root, dirs, files in os.walk(export_path):
			# Match any folder path containing the base name
			if base_name.lower() in root.lower():
				for file in files:
					if (file.lower().endswith(".png")):
						if ("alb" in file.lower() or "nrm" in file.lower()) and "albgry" not in file.lower():
							src = os.path.join(root, file)
							dst = unique_name(textures_folder, file)
							shutil.copy2(src, dst)
							print(f"Copied {file} -> {dst}")
